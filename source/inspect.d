module inspect;
import std.conv;
import std.traits;
import std.string;

struct Inspect(T)
{
	string[] fields = getFields!T[1];
	mixin(generatePOD!T);
	mixin(generateGet!T);
	mixin(generateSet!T);		
	
	T fromPOD(typeof(POD) pod)
	{
		POD = pod;
		T obj = new T();
		enum members = getFields!T;
		static foreach(i, member; members[1])
			__traits(getMember, obj, member) = 
				mixin("to!%s(get(\"%s\"))".format(members[0][i],member));
		return obj;
	}
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

private string generatePOD(T)()
{
	enum structName = toLower!string(T.stringof);
	string output = "private struct %s {".format(structName);
	output ~= generateFields!T;
	output ~= "}";
	output ~= structName ~ " POD;";
	output ~= "alias POD this;";
	return output;
}

private string generateFields(T)()
{
	enum fields = getFields!T;
	string output;
	static foreach (i, field; fields[0])
		output ~=  "%s %s;".format(field, fields[1][i]);
	return output;
}

private string generateGet(T)()
{
	enum fields = getFields!T;
	string output;
	output ~= "auto get(string memberName) {";
	output ~= "switch(memberName) {";
	static foreach (field; fields[1])
	{
		output ~= "case \"" ~ field ~ "\":";
		output ~= "return to!string(this." ~ field ~ ");";
	}
	output ~= "default: return null;}}";
	return output;
}

private string generateSet(T)()
{
	enum fields = getFields!T;
	string output;
	output ~= "void set(string memberName, string memberValue) {";
	output ~= "switch(memberName) {";
	static foreach (i, field; fields[1])
	{	
		output ~= "case \"" ~ field ~ "\":";
		output ~= "this.%s = to!%s(memberValue);".format(field, fields[0][i]);
		output ~= " break;";
	}
	output ~= "default: break;}}";
	return output;
}