module mx;
import dao;
import contato;

void main()
{
	foreach(contato; readDAO!Contato)
		contato.sayHello;
}
