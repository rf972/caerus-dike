
#include <iostream>
#include <string>
#include <fstream>
#include <streambuf>
#include <regex>

#include <sqlite3.h>

#include <httpparser/request.h>
#include <httpparser/httprequestparser.h>

#include "rapidxml.hpp"

extern "C" {
extern int sqlite3_csv_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi);
}

static int db_callback(void* data, int argc, char** argv, char** azColName);


int main (int argc, char *argv[]) 
{
    sqlite3 *db;    
    int rc;
    char  * errmsg;
    bool debug_mode = false;

    if(argc > 1){ // debug mode
        debug_mode = true;
    }

    std::string pipeInput;
        
    if(debug_mode) {
        std::ifstream t("http_select.txt");
        pipeInput = std::string((std::istreambuf_iterator<char>(t)), std::istreambuf_iterator<char>());
        pipeInput = std::regex_replace(pipeInput, std::regex("(?:\\r\\n|\\n|\\r)"), "\r\n");
    } else {
        std::string input;
        while (getline(std::cin, input)) { pipeInput += input + "\n"; }
    }    
    
    httpparser::Request request;    
    httpparser::HttpRequestParser parser;
    httpparser::HttpRequestParser::ParseResult res = parser.parse(request, pipeInput.c_str(), pipeInput.c_str() + pipeInput.length());
    if( res == httpparser::HttpRequestParser::ParsingCompleted ) {
        //std::cout << request.inspect() << std::endl;
        if(debug_mode) { std::cout << request.uri << std::endl; }
    } else {
        std::cerr << "Parsing failed" << std::endl;
        //std::cout << "Parsing failed" << std::endl;
        return 1;
    }

    std::string sqlPath = "/data";
    if(debug_mode) { sqlPath = "."; }

    std::string sqlFileName =  sqlPath + request.uri.substr(0, request.uri.find("?"));

	rapidxml::xml_document<> doc;
	rapidxml::xml_node<> * root_node;
    request.content.push_back('\0');
	// Parse the buffer using the xml file parsing library into doc 
	doc.parse<0>(&request.content[0]);
	// Find our root node
	root_node = doc.first_node("SelectObjectContentRequest");
    //for (xml_node<> * node = root_node->first_node("Brewery"); brewery_node; brewery_node = brewery_node->next_sibling())
    rapidxml::xml_node<> * expression_node = root_node->first_node("Expression");
    if(debug_mode) { std::cout << expression_node->value() << std::endl; }

    std::string sqlQuery = expression_node->value();    

    rc = sqlite3_open(":memory:", &db);

    if( rc ) {
        std::cerr << "Can't open database: " << sqlite3_errmsg(db);
        return(1);
    } else {
        if(debug_mode) { std::cout << "Opened database successfully\n";}
    }

    //sqlite3_enable_load_extension(db, 1);
    //rc = sqlite3_load_extension( db, "./csv.so", 0, &errmsg);
    // sqlite3_auto_extension(sqlite3_csv_init);
    sqlite3_csv_init(db, &errmsg, NULL);
    if(rc != SQLITE_OK) {
        std::cerr << "Can't load extention: " << errmsg << std::endl;
        sqlite3_free(errmsg); 
    }

    std::string sqlCreateVirtualTable = "CREATE VIRTUAL TABLE S3Object USING csv(filename='";
    sqlCreateVirtualTable += sqlFileName;
    sqlCreateVirtualTable += "', header=true);" ;

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
