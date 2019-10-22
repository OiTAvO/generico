module mx;
import dao;
import pbar;
import std.stdio;

void main()
{
	foreach(contato; readDAO!Contato)
		writeln(contato.nome, " ", contato.id);
}
