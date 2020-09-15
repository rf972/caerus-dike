
#include <iostream>
#include <sqlite3.h> 

static int callback(void* data, int argc, char** argv, char** azColName);

int main (int argc, char *argv[]) 
{
    sqlite3 *db;    
    int rc;
    char  * errmsg;
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

    rc = sqlite3_exec(db, query.c_str(), callback, NULL, &errmsg);
    if(rc != SQLITE_OK) {
        std::cerr << "Can't execute query: " << errmsg << std::endl;
        sqlite3_free(errmsg); 
    }

    sqlite3_close(db);
    return(0);
}

static int callback(void* data, int argc, char** argv, char** azColName) 
{ 
    int i; 
    fprintf(stderr, "%s: ", (const char*)data); 
  
    for (i = 0; i < argc; i++) { 
        printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL"); 
    } 
  
    printf("\n"); 
    return 0; 
} 
