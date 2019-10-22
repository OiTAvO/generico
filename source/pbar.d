module pbar;
import std.conv;
import std.stdio;

class Pessoa
{
	string sobrenome;
	int idade;
}


class Contato
{
    long id;
	string nome;
	
	void sayHello()
	{
		writeln("Hello from ", nome, "!!");
	}
}