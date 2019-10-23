module dao;
import ddbc;
import contato;
import inspect;
import std.stdio;

T[] readDAO(T)()
{
	string urlDb = "sqlite:source/meudb.sqlite";
    
    auto conn = createConnection(urlDb);
    scope(exit) conn.close();
    
    Statement stmt = conn.createStatement();
    scope(exit) stmt.close();

	T[] lista;
	auto obj = new Inspect!T;
    foreach(ref e; stmt.select!(typeof(obj.POD)))
		lista ~= obj.fromPOD(e);
	return lista;
}
