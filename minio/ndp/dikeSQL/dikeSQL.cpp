
#include <iostream>
#include <string>
#include <fstream>
#include <streambuf>
#include <regex>

#include <sqlite3.h>

#include <httpparser/request.h>
#include <httpparser/httprequestparser.h>

#include "rapidxml.hpp"


static int db_callback(void* data, int argc, char** argv, char** azColName);


int main (int argc, char *argv[]) 
{
    sqlite3 *db;    
    int rc;
    char  * errmsg;

    std::string pipeInput;
    
    // while (getline(std::cin, pipeInput)) { std::cout << pipeInput << std::endl; }
    std::ifstream t("http_select.txt");
    pipeInput = std::string((std::istreambuf_iterator<char>(t)), std::istreambuf_iterator<char>());
    
    pipeInput = std::regex_replace(pipeInput, std::regex("(?:\\r\\n|\\n|\\r)"), "\r\n");

    
    httpparser::Request request;    
    httpparser::HttpRequestParser parser;
    httpparser::HttpRequestParser::ParseResult res = parser.parse(request, pipeInput.c_str(), pipeInput.c_str() + pipeInput.length());
    if( res == httpparser::HttpRequestParser::ParsingCompleted ) {
        //std::cout << request.inspect() << std::endl;
        std::cout << request.uri << std::endl;
    } else {
        std::cerr << "Parsing failed" << std::endl;
        return 1;
    }

    std::string sqlPath = ".";
    if(argc > 1){
        sqlPath = std::string(argv[1]);
    }

    std::string sqlFileName =  sqlPath + request.uri.substr(0, request.uri.find("?"));

	rapidxml::xml_document<> doc;
	rapidxml::xml_node<> * root_node;
    request.content.push_back('\0');
	// Parse the buffer using the xml file parsing library into doc 
	doc.parse<0>(&request.content[0]);
	// Find our root node
	root_node = doc.first_node("SelectObjectContentRequest");
    //for (xml_node<> * node = root_node->first_node("Brewery"); brewery_node; brewery_node = brewery_node->next_sibling())
    std::cout << root_node->first_node()->name() << std::endl;
    rapidxml::xml_node<> * expression_node = root_node->first_node("Expression");
    std::cout << expression_node->value() << std::endl;

    std::string sqlQuery = expression_node->value();    

    /*
    std::string query = ("SELECT s.Location, s.PopTotal, s.PopDensity, s.Time  FROM temp.t1 AS s "
                    "WHERE s.Location LIKE '%United States of America (and dependencies)%' AND s.Time='2020' ;"
                    ); 
    */
    //"SELECT s.Location, s.PopTotal, s.PopDensity, s.Time  FROM s3object AS s WHERE s.Location LIKE '%United States of America (and dependencies)%' AND s.Time='2020' "

    std::cout << "Welcome to " << argv[0] << std::endl;

    rc = sqlite3_open(":memory:", &db);

    if( rc ) {
        std::cerr << "Can't open database: " << sqlite3_errmsg(db);
        return(1);
    } else {
        std::cout << "Opened database successfully\n";
    }

    sqlite3_enable_load_extension(db, 1);
    rc = sqlite3_load_extension( db, "./csv.so", 0, &errmsg);
    if(rc != SQLITE_OK) {
        std::cerr << "Can't load extention: " << errmsg << std::endl;
        sqlite3_free(errmsg); 
    }

    std::string sqlCreateVirtualTable = "CREATE VIRTUAL TABLE s3object USING csv(filename='";
    sqlCreateVirtualTable += sqlFileName;
    sqlCreateVirtualTable += "', header=true);" ;

    //rc = sqlite3_exec(db, "CREATE VIRTUAL TABLE temp.t1 USING csv(filename='TotalPopulation.csv', header=true);", NULL, NULL, &errmsg);
    //rc = sqlite3_exec(db, "CREATE VIRTUAL TABLE s3object USING csv(filename='TotalPopulation.csv', header=true);", NULL, NULL, &errmsg);
    rc = sqlite3_exec(db, sqlCreateVirtualTable.c_str(), NULL, NULL, &errmsg);
    if(rc != SQLITE_OK) {
        std::cerr << "Can't create virtual table: " << errmsg << std::endl;
        sqlite3_free(errmsg); 
    }

    rc = sqlite3_exec(db, sqlQuery.c_str(), db_callback, NULL, &errmsg);
    if(rc != SQLITE_OK) {
        std::cerr << "Can't execute query: " << errmsg << std::endl;
        sqlite3_free(errmsg); 
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
        std::cout << (argv[i] ? argv[i] : "NULL") << " ";
    } 
  
    std::cout << std::endl;
    //printf("\n"); 
    return 0; 
} 

/*
static int request_callback(http_parser* parser, const char *at, size_t length) 
{
  return 0;
}
*/