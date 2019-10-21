module mx;
import inspect;
import std.stdio;

class Pessoa
{
	string nome;
	string sobrenome;
	int idade;
	string cpf;
}

void main()
{
	Pessoa p = new Pessoa();
	Inspect!Pessoa iPessoa;
	foreach(field; iPessoa.fields)
	{
		writeln(iPessoa.get(field));
	}
}
