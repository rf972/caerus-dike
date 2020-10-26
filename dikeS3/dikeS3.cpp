#include <Poco/Net/ServerSocket.h>
#include <Poco/Net/HTTPServer.h>
#include <Poco/Net/HTTPRequestHandler.h>
#include <Poco/Net/HTTPRequestHandlerFactory.h>
#include <Poco/Net/HTTPResponse.h>
#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/Net/HTTPServerResponse.h>
#include <Poco/Util/ServerApplication.h>

#include <Poco/Util/AbstractConfiguration.h>
#include <Poco/Util/XMLConfiguration.h>


#include <aws/event-stream/event_stream.h>
#include <aws/common/encoding.h>
#include <aws/checksums/crc.h> 

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <stdlib.h>
#include <ctype.h>
#include <memory.h>

#include <sqlite3.h>

extern "C" {
extern int sqlite3_csv_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi);
extern int sqlite3_tbl_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi);
}

using namespace Poco::Net;
using namespace Poco::Util;
using namespace std;

static void dike_debug_print_buffer(const void * buffer, int len);

const char MESSAGE_TYPE_HEADER[] = ":message-type";
const char MESSAGE_TYPE_EVENT[] = "event";

const char CONTENT_TYPE_HEADER[] = ":content-type";
const char CONTENT_TYPE_OCTET_STREAM[] = "application/octet-stream";

const char EVENT_TYPE_HEADER[] = ":event-type";
const char EVENT_TYPE_RECORDS[] = "Records";
const char EVENT_TYPE_END[] = "End";
const char EVENT_TYPE_CONT[] = "Cont";

const char ERROR_CODE_HEADER[] = ":error-code";
const char ERROR_MESSAGE_HEADER[] = ":error-message";
const char EXCEPTION_TYPE_HEADER[] = ":exception-type";


class DikeByteBuffer
{
  const int DIKE_BYTE_BUFFER_SIZE = 64<<10; 
  typedef int (*Callback_t)(DikeByteBuffer * buf, void * context);
  public:
    DikeByteBuffer() 
    {
      m_Buffer = (char*) malloc(DIKE_BYTE_BUFFER_SIZE);
      memset(m_Buffer, 0, DIKE_BYTE_BUFFER_SIZE);
      m_Pos = 0;
      m_Context = NULL;
      m_Callback = NULL;
    }
    ~DikeByteBuffer(){
      free(m_Buffer);
    }
    void SetCallback(Callback_t callback, void * context)
    {
      m_Callback = callback;
      m_Context = context;
    }
    void Write(const char * buf, int len){
      //cout << "Write: " <<  len << endl;
      if(m_Pos + len > DIKE_BYTE_BUFFER_SIZE){
        m_Callback(this, m_Context);
        m_Pos = 0;
      }
      memcpy(m_Buffer + m_Pos, buf, len);
      m_Pos += len;
    }

    void Flush(void) {         
      m_Callback(this, m_Context);
      m_Pos = 0;
    }

    char * GetBuffer()
    {
      return m_Buffer;
    }
    int GetLen()
    {
      return m_Pos;
    }
  private:
    char * m_Buffer;
    int m_Pos;
    Callback_t m_Callback;
    void * m_Context;
};


static int db_callback(void* data, int argc, char** argv, char** azColName) 
{ 
    int i; 
    DikeByteBuffer * ddb = (DikeByteBuffer *)data;

    for (i = 0; i < argc; i++) { 
        if(argv[i]){
            if(strchr(argv[i],',')){
            //if (std::string(argv[i]).find(',') != std::string::npos) {
                //std::cout << '"' << argv[i] << '"';
                ddb->Write("\"", 1);
                ddb->Write(argv[i], strlen(argv[i]));
                ddb->Write("\"", 1);
            } else {
                //std::cout << argv[i];
                ddb->Write(argv[i], strlen(argv[i]));
            }
        } else {
            //std::cout << "NULL";
            ddb->Write("NULL", 4);
        }
        if(i < argc -1) {
            //std::cout << ",";
            ddb->Write(",", 1);
        }
    } 
  
    //std::cout << std::endl;
    ddb->Write("\n", 1);
    return 0; 
} 

class MyRequestHandler : public HTTPRequestHandler
{
public:
  ostream * m_RespStream;
  virtual void handleRequest(HTTPServerRequest &req, HTTPServerResponse &resp)
  {
    resp.setStatus(HTTPResponse::HTTP_OK);
    resp.set("Content-Security-Policy", "block-all-mixed-content");
    resp.set("Vary", "Origin");
    resp.set("X-Amz-Request-Id", "1640125B8EDA3957");
    resp.set("X-Xss-Protection", "1; mode=block");

    resp.setContentType("application/octet-stream");    
    resp.setChunkedTransferEncoding(true);    
    resp.setKeepAlive(true);
    
    ostream& out = resp.send();
    m_RespStream = &out;

    int rc;
    char  * errmsg;
 
    sqlite3 *db;
    rc = sqlite3_open(":memory:", &db);
    if( rc ) {
        cout << "Can't open database: " << sqlite3_errmsg(db);
        return;
    }

    rc = sqlite3_csv_init(db, &errmsg, NULL);
    if(rc != SQLITE_OK) {
        cout << "Can't load csv extention: " << errmsg << std::endl;
        sqlite3_free(errmsg);
        return;
    }

    rc = sqlite3_tbl_init(db, &errmsg, NULL);
    if(rc != SQLITE_OK) {
        cout << "Can't load tbl extention: " << errmsg << std::endl;
        sqlite3_free(errmsg);
        return;
    }

    string sqlPath = "/data";
    string sqlFileName = sqlPath + req.getURI().substr(0, req.getURI().find("?"));

    cout << sqlFileName << endl;
    
    string sqlCreateVirtualTable;

    bool tbl_mode = false;
    size_t extIndex = sqlFileName.find(".tbl");
    if (extIndex != string::npos) {
        tbl_mode = true;
    }

    if(!tbl_mode){
        sqlCreateVirtualTable = "CREATE VIRTUAL TABLE S3Object USING csv(filename='";
        sqlCreateVirtualTable += sqlFileName + "'";
        sqlCreateVirtualTable += ", header=true" ;
    }

    if(tbl_mode){         
        string schemaFileName = sqlFileName.substr(0, extIndex) + ".schema";                   

        sqlCreateVirtualTable = "CREATE VIRTUAL TABLE S3Object USING tbl(filename='";
        sqlCreateVirtualTable += sqlFileName + "'";
        ifstream fs(schemaFileName);
        string schema((istreambuf_iterator<char>(fs)), istreambuf_iterator<char>());
        
        if(!schema.empty()) {
            sqlCreateVirtualTable += ", schema=CREATE TABLE S3Object (" + schema + ")";
        }
    }

    sqlCreateVirtualTable += ");";

    rc = sqlite3_exec(db, sqlCreateVirtualTable.c_str(), NULL, NULL, &errmsg);
    if(rc != SQLITE_OK) {
        cout << "Can't create virtual table: " << errmsg << endl;
        sqlite3_free(errmsg);
        sqlite3_close(db);
        return;
    }

    AbstractConfiguration *cfg = new XMLConfiguration(req.stream());
    string sqlQuery = cfg->getString("Expression");
    cout << "SQL " << sqlQuery << endl;

    DikeByteBuffer dbb = DikeByteBuffer();
    dbb.SetCallback(DikeByteBufferCallback, this);

    rc = sqlite3_exec(db, sqlQuery.c_str(), db_callback, (void *) &dbb, &errmsg);
    if(rc != SQLITE_OK) {
        cout << "Can't execute query: " << errmsg << std::endl;
        sqlite3_free(errmsg);
        sqlite3_close(db);
        return;
    }

    sqlite3_close(db);

    /*
    DikeByteBuffer dbb = DikeByteBuffer();
    dbb.SetCallback(DikeByteBufferCallback, this);
    std::string str = "1,155190,7706,1,17.0,21168.23,0.04,0.02,N,O,1996-03-13,1996-02-12,1996-03-22,DELIVER IN PERSON,TRUCK,egular courts above the\n";

    for(int m = 0; m < 1000000; m++){
      dbb.Write(str.c_str(), str.length());
    }
    */
    dbb.Flush();
    SendEnd(*m_RespStream);
    out.flush();    
  }

  static int DikeByteBufferCallback(DikeByteBuffer * buf, void * context)
  {
    //cout << "DikeByteBufferCallback: " <<  buf->GetLen() << endl;
    MyRequestHandler * h = (MyRequestHandler *)context;
    h->SendPayload(*h->m_RespStream, buf->GetBuffer(), buf->GetLen());
    return 0;
  }

  int SendPayload(ostream& outStream, char * data, int len)
  {
    struct aws_array_list headers;
    struct aws_allocator *alloc = aws_default_allocator();
    struct aws_event_stream_message msg;    
    struct aws_byte_buf payload = aws_byte_buf_from_array(data, len);
    
    aws_event_stream_headers_list_init(&headers, alloc);        
    aws_event_stream_add_string_header(&headers, MESSAGE_TYPE_HEADER, sizeof(MESSAGE_TYPE_HEADER) - 1, MESSAGE_TYPE_EVENT, sizeof(MESSAGE_TYPE_EVENT) - 1, 0);
    aws_event_stream_add_string_header(&headers, CONTENT_TYPE_HEADER, sizeof(CONTENT_TYPE_HEADER) - 1, CONTENT_TYPE_OCTET_STREAM, sizeof(CONTENT_TYPE_OCTET_STREAM) - 1, 0);
    aws_event_stream_add_string_header(&headers, EVENT_TYPE_HEADER, sizeof(EVENT_TYPE_HEADER) - 1, EVENT_TYPE_RECORDS, sizeof(EVENT_TYPE_RECORDS) - 1, 0);

    aws_event_stream_message_init(&msg, alloc, &headers, &payload);

    //dike_debug_print_buffer(aws_event_stream_message_buffer(&msg), aws_event_stream_message_total_length(&msg));
    outStream.write((const char *)aws_event_stream_message_buffer(&msg), aws_event_stream_message_total_length(&msg));

    aws_byte_buf_clean_up(&payload);
    aws_event_stream_message_clean_up(&msg);
    aws_event_stream_headers_list_cleanup(&headers);
  
    return 0;
  }
  int SendCont(ostream& outStream)
  {
    struct aws_array_list headers;
    struct aws_allocator *alloc = aws_default_allocator();
    struct aws_event_stream_message msg;        
    
    aws_event_stream_headers_list_init(&headers, alloc);        
    aws_event_stream_add_string_header(&headers, MESSAGE_TYPE_HEADER, sizeof(MESSAGE_TYPE_HEADER) - 1, MESSAGE_TYPE_EVENT, sizeof(MESSAGE_TYPE_EVENT) - 1, 0);    
    aws_event_stream_add_string_header(&headers, EVENT_TYPE_HEADER, sizeof(EVENT_TYPE_HEADER) - 1, EVENT_TYPE_CONT, sizeof(EVENT_TYPE_CONT) - 1, 0);
    aws_event_stream_message_init(&msg, alloc, &headers, NULL);    
    outStream.write((const char *)aws_event_stream_message_buffer(&msg), aws_event_stream_message_total_length(&msg));    
    aws_event_stream_message_clean_up(&msg);
    aws_event_stream_headers_list_cleanup(&headers);
  
    return 0;
  }

  int SendEnd(ostream& outStream)
  {
    struct aws_array_list headers;
    struct aws_allocator *alloc = aws_default_allocator();
    struct aws_event_stream_message msg;        
    
    aws_event_stream_headers_list_init(&headers, alloc);        
    aws_event_stream_add_string_header(&headers, MESSAGE_TYPE_HEADER, sizeof(MESSAGE_TYPE_HEADER) - 1, MESSAGE_TYPE_EVENT, sizeof(MESSAGE_TYPE_EVENT) - 1, 0);    
    aws_event_stream_add_string_header(&headers, EVENT_TYPE_HEADER, sizeof(EVENT_TYPE_HEADER) - 1, EVENT_TYPE_END, sizeof(EVENT_TYPE_END) - 1, 0);
    aws_event_stream_message_init(&msg, alloc, &headers, NULL);    
    outStream.write((const char *)aws_event_stream_message_buffer(&msg), aws_event_stream_message_total_length(&msg));    
    aws_event_stream_message_clean_up(&msg);
    aws_event_stream_headers_list_cleanup(&headers);
  
    return 0;
  }

private:
  static int count;
};

int MyRequestHandler::count = 0;

class MyRequestHandlerFactory : public HTTPRequestHandlerFactory
{
public:
  virtual HTTPRequestHandler* createRequestHandler(const HTTPServerRequest &)
  {
    return new MyRequestHandler;
  }
};

class MyServerApp : public ServerApplication
{
protected:
  int main(const vector<string> &)
  {
    HTTPServer s(new MyRequestHandlerFactory, ServerSocket(9000), new HTTPServerParams);

    s.start();
    cout << endl << "Server started" << endl;

    waitForTerminationRequest();  // wait for CTRL-C or kill

    cout << endl << "Shutting down..." << endl;
    s.stop();

    return Application::EXIT_OK;
  }
};

int main(int argc, char** argv)
{
  MyServerApp app;

  return app.run(argc, argv);
}

static void dike_debug_print_buffer(const void * buffer, int len)
{
    unsigned char * buf = (unsigned char *)buffer;
    int i;

    for(i = 0; i < len; i++) {
        printf("%d ",(char)buf[i]);
    }
    printf("\n\n");


    for(i = 0; i < len; i++) {
        printf("%x ",buf[i]);
    }
    printf("\n\n");

    for(i = 0; i < len; i++) {
        if(isalnum(buf[i])){
            printf("%c ",buf[i]);
        } else {
            printf("%d ",buf[i]);
        }        
    }
    printf("\n\n");    

}


//java.nio.HeapByteBuffer[pos=125 lim=165 cap=131072]
// 0 0 0 113 0 0 0 85 -70 -111 -77 109
