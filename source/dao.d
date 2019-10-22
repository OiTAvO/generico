module dao;
import ddbc;
import pbar;
import std.stdio;
import inspect;

T[] readDAO(T)()
{
	string urlDb = "sqlite:source/meudb.sqlite";
    
    auto conn = createConnection(urlDb);
    scope(exit) conn.close();
    
    Statement stmt = conn.createStatement();
    scope(exit) stmt.close();
    
	T[] lista;
	Inspect!T obj;
    foreach(ref e; stmt.select!(typeof(obj.POD)))
		lista ~= obj.fromPOD(e);
	return lista;
}