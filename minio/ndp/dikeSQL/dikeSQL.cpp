
#include <iostream>
#include <string>
#include <fstream>
#include <streambuf>
#include <regex>
#include <fstream>
#include <streambuf>

#include <sqlite3.h>

#include <httpparser/request.h>
#include <httpparser/httprequestparser.h>

#include "rapidxml.hpp"

extern "C" {
extern int sqlite3_csv_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi);
extern int sqlite3_tbl_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi);
}

static int db_callback(void* data, int argc, char** argv, char** azColName);

typedef enum debug_mode_e {
    DEBUG_MODE_NONE         = 0,
    DEBUG_MODE_HTTP         = 1,
    DEBUG_MODE_LOCAL        = 2,
    DEBUG_MODE_LOCAL_TBL    = 3
} debug_mode_t;

int main (int argc, char *argv[]) 
{
    sqlite3 *db;    
    int rc;
    char  * errmsg;
    debug_mode_t debug_mode = DEBUG_MODE_NONE;

    if(argc > 1){ // debug mode
        debug_mode = (debug_mode_t)std::stoi(std::string(argv[1]), nullptr);
    }

    std::string sqlFileName;
    std::string sqlQuery;

    std::string pipeInput;

    if (debug_mode == DEBUG_MODE_NONE) {
        std::string input;
        while (getline(std::cin, input)) { pipeInput += input + "\n"; }
    } else if(debug_mode == DEBUG_MODE_HTTP) {
        std::ifstream t("http_select.txt");
        pipeInput = std::string((std::istreambuf_iterator<char>(t)), std::istreambuf_iterator<char>());
        pipeInput = std::regex_replace(pipeInput, std::regex("(?:\\r\\n|\\n|\\r)"), "\r\n");
    } 
    
    if(debug_mode < DEBUG_MODE_LOCAL) {
        httpparser::Request request;
        httpparser::HttpRequestParser parser;
        httpparser::HttpRequestParser::ParseResult res = parser.parse(request, pipeInput.c_str(), pipeInput.c_str() + pipeInput.length());
        if( res == httpparser::HttpRequestParser::ParsingCompleted ) {            
            if(debug_mode != DEBUG_MODE_NONE) { std::cout << request.uri << std::endl; }
        } else {
            std::cerr << "Parsing failed" << std::endl;            
            return 1;
        }

        std::string sqlPath = "/data";
        if(debug_mode) { sqlPath = "."; }
        sqlFileName =  sqlPath + request.uri.substr(0, request.uri.find("?"));

        rapidxml::xml_document<> doc;
        rapidxml::xml_node<> * root_node;
        request.content.push_back('\0');        
        doc.parse<0>(&request.content[0]);        
        root_node = doc.first_node("SelectObjectContentRequest");        
        rapidxml::xml_node<> * expression_node = root_node->first_node("Expression");
        if(debug_mode != DEBUG_MODE_NONE) { std::cout << expression_node->value() << std::endl; }
        sqlQuery = expression_node->value();    
    }

    if(debug_mode == DEBUG_MODE_LOCAL || debug_mode == DEBUG_MODE_LOCAL_TBL){
        if(argc < 4){
            std::cerr << "Usage: " << argv[0] << " 3 file.tbl \"SQL query\" " << std::endl;
            return 1;
        }
        sqlFileName = std::string(argv[2]);
        sqlQuery = std::string(argv[3]);
    }

    sqlite3_soft_heap_limit64(1<<30);
    sqlite3_hard_heap_limit64(2<<30);

    rc = sqlite3_open(":memory:", &db);

    if( rc ) {
        std::cerr << "Can't open database: " << sqlite3_errmsg(db);
        return(1);
    }

    rc = sqlite3_csv_init(db, &errmsg, NULL);
    if(rc != SQLITE_OK) {
        std::cerr << "Can't load csv extention: " << errmsg << std::endl;
        sqlite3_free(errmsg);
        return 1;
    }

    rc = sqlite3_tbl_init(db, &errmsg, NULL);
    if(rc != SQLITE_OK) {
        std::cerr << "Can't load tbl extention: " << errmsg << std::endl;
        sqlite3_free(errmsg);
        return 1;
    }

    std::string sqlCreateVirtualTable;

    bool tbl_mode = false;
    size_t extIndex = sqlFileName.find_last_of(".");
    if (extIndex != std::string::npos && sqlFileName.substr(extIndex, sqlFileName.length()) == ".tbl") {
        tbl_mode = true;
    }

    if(!tbl_mode){
        sqlCreateVirtualTable = "CREATE VIRTUAL TABLE S3Object USING csv(filename='";
        sqlCreateVirtualTable += sqlFileName + "'";
        sqlCreateVirtualTable += ", header=true" ;
    }

    if(tbl_mode){         
        std::string schemaFileName;
        if (extIndex == std::string::npos){
            schemaFileName = sqlFileName + ".schema";
        } else {
            schemaFileName = sqlFileName.substr(0, extIndex) + ".schema";
        }

        sqlCreateVirtualTable = "CREATE VIRTUAL TABLE S3Object USING tbl(filename='";
        sqlCreateVirtualTable += sqlFileName + "'";
        std::ifstream fs(schemaFileName);
        std::string schema((std::istreambuf_iterator<char>(fs)), std::istreambuf_iterator<char>());

        //sqlCreateVirtualTable += ", schema=CREATE TABLE S3Object (r_regionkey INTEGER,r_name TEXT,r_comment TEXT)";
        if(!schema.empty()){
            sqlCreateVirtualTable += ", schema=CREATE TABLE S3Object (" + schema + ")";
        }
    }

    sqlCreateVirtualTable += ");";

    rc = sqlite3_exec(db, sqlCreateVirtualTable.c_str(), NULL, NULL, &errmsg);
    if(rc != SQLITE_OK) {
        std::cerr << "Can't create virtual table: " << errmsg << std::endl;
        sqlite3_free(errmsg);
        sqlite3_close(db);
        return 1;
    }

    rc = sqlite3_exec(db, sqlQuery.c_str(), db_callback, NULL, &errmsg);
    if(rc != SQLITE_OK) {
        std::cerr << "Can't execute query: " << errmsg << std::endl;
        sqlite3_free(errmsg);
        sqlite3_close(db);
        return 1;
    }

    // DROP TABLE [IF EXISTS] [schema_name.]table_name;

    sqlite3_close(db);
    return(0);
}

static int db_callback(void* data, int argc, char** argv, char** azColName) 
{ 
    int i; 
    //fprintf(stderr, "%s: ", (const char*)data); 
  
    for (i = 0; i < argc; i++) { 
        //printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
        //std::cout << (argv[i] ? argv[i] : "NULL");
        if(argv[i]){
            if (std::string(argv[i]).find(',') != std::string::npos) {
                // Comma found in data
                std::cout << '"' << argv[i] << '"';
            } else {
                std::cout << argv[i];
            }
        } else {
            std::cout << "NULL";
        }
        if(i < argc -1) {
            std::cout << ",";
        }
    } 
  
    std::cout << std::endl;
    //printf("\n"); 
    return 0; 
} 
