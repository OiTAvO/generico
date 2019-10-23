module contato;
import std.stdio;

class Contato
{
    long id;
	string nome;
	
	void sayHello()
	{
		writeln("Hello from ", nome, "!!");
	}
}