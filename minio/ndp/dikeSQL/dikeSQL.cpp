
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
    std::ifstream t("http_data.txt");
    pipeInput = std::string((std::istreambuf_iterator<char>(t)), std::istreambuf_iterator<char>());
    
    pipeInput = std::regex_replace(pipeInput, std::regex("(?:\\r\\n|\\n|\\r)"), "\r\n");

    
    httpparser::Request request;    
    httpparser::HttpRequestParser parser;
    httpparser::HttpRequestParser::ParseResult res = parser.parse(request, pipeInput.c_str(), pipeInput.c_str() + pipeInput.length());
    if( res == httpparser::HttpRequestParser::ParsingCompleted ) {
        std::cout << request.inspect() << std::endl;        
    } else {
        std::cerr << "Parsing failed" << std::endl;
        return 1;
    }


	rapidxml::xml_document<> doc;
	rapidxml::xml_node<> * root_node;
	// Read the xml file into a vector
	//ifstream theFile ("beerJournal.xml");
	//vector<char> buffer((istreambuf_iterator<char>(theFile)), istreambuf_iterator<char>());
    request.content.push_back('\0');
	//buffer.push_back('\0');
	// Parse the buffer using the xml file parsing library into doc 
	doc.parse<0>(&request.content[0]);
	// Find our root node
	root_node = doc.first_node("SelectObjectContentRequest");
    //for (xml_node<> * node = root_node->first_node("Brewery"); brewery_node; brewery_node = brewery_node->next_sibling())
    std::cout << root_node->first_node()->name() << std::endl;
    rapidxml::xml_node<> * expression_node = root_node->first_node("Expression");
    std::cout << expression_node->value() << std::endl;

    return 0;
    /*
    std::string query = ("SELECT Location, PopTotal, PopDensity, Time  FROM temp.t1 "
                    "WHERE Location LIKE '%United States of America (and dependencies)%' AND Time='2020' ;"
                    ); 
    */
    std::string query = ("SELECT s.Location, s.PopTotal, s.PopDensity, s.Time  FROM temp.t1 AS s "
                    "WHERE s.Location LIKE '%United States of America (and dependencies)%' AND s.Time='2020' ;"
                    ); 

   //std::string query = ("SELECT * FROM temp.t1 LIMIT 5;");

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

    rc = sqlite3_exec(db, "CREATE VIRTUAL TABLE temp.t1 USING csv(filename='TotalPopulation.csv', header=true);", NULL, NULL, &errmsg);
    if(rc != SQLITE_OK) {
        std::cerr << "Can't create virtual table: " << errmsg << std::endl;
        sqlite3_free(errmsg); 
    }

    rc = sqlite3_exec(db, query.c_str(), db_callback, NULL, &errmsg);
    if(rc != SQLITE_OK) {
        std::cerr << "Can't execute query: " << errmsg << std::endl;
        sqlite3_free(errmsg); 
    }

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