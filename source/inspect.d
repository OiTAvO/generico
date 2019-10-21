module inspect;
import std.conv;
import std.traits;
import std.array : join;

struct Inspect(T)
{
	string[] fields = getFields!T[1];
	mixin generateAll!T;
}

private struct Field(T)
{
	T obj;
	
	string get() {return to!string(obj); }
	void set(string value) { obj = to!T(value); }
}

private string[][2] getFields(T)()
{
	string[][2] members;
	static if (is(T == class) || is(T == struct))
		static foreach(member; [ __traits(allMembers, T) ])
			static if (!isFunction!(__traits(getMember, T, member)))
				static if (member != "Monitor")
				{
					members[0] ~= typeof(__traits(getMember, T, member)).stringof;
					members[1] ~= member;
				}
	return members;
	
}

private string[] generateFields(T)()
{
	string[] output;
	enum fields = getFields!T;
	static foreach (i, field; fields[0])
		output ~= "private Field!" ~ field ~ " " ~ fields[1][i] ~ ";";
	return output;
}

private string[] generateGet(T)()
{
	string[] output;
	enum fields = getFields!T;
	output ~= "auto get(string memberName) {";
	output ~= "switch(memberName) {";
	static foreach (field; fields[1])
	{
		output ~= "case \"" ~ field ~ "\":";
		output ~= "return this." ~ field ~ ".get();";
	}
	output ~= "default: return null;}}";
	return output;
}

private string[] generateSet(T)()
{
	string[] output;
	enum fields = getFields!T;
	output ~= "void set(string memberName, string memberValue) {";
	output ~= "switch(memberName) {";
	static foreach (field; fields[1])
	{	
		output ~= "case \"" ~ field ~ "\":";
		output ~= "this." ~ field ~ ".set(memberValue); break;";
	}
	output ~= "default: break;}}";
	return output;
}

private mixin template generateAll(T)
{
	mixin((generateFields!T).join("\n"));
	mixin((generateGet!T).join("\n"));
	mixin((generateSet!T).join("\n"));
}
