module inspect;
import std.conv;
import std.string;
import std.traits;

/// Template class that generates POD object and makes it accessible
class Inspect(T) if (is(T == class) || is(T == struct))
{
    /// array with the generated POD field names.
    enum string[] fields = Fields[1];

    /// POD object is Voldemort type
    auto POD = generatePOD!T;
    alias POD this;

    /// returns a new T instance by the given POD.
    T fromPOD(typeof(POD) pod)
    {
        POD = pod;
        T obj = new T();
        static foreach (i, member; Fields[1])
            __traits(getMember, obj, member) = mixin(
                    "to!%s(get(\"%s\"))".format(Fields[0][i], member));
        return obj;
    }

    deprecated void fillPOD(T obj)
    {
        static foreach (member; Fields[1])
            set(member, to!string(__traits(getMember, obj, member)));
    }

private:
    enum Fields = getFields!T;

    /// returns string memberValue by the given POD memberName
    string get(string memberName)
    {
        mixin(generateGet!T);
    }

    /// set string memberValue by the given POD memberName
    void set(string memberName, string memberValue)
    {
        mixin(generateSet!T);
    }
}

///
unittest
{
    import contato;

    Contato[] lista;
    auto obj = new Inspect!Contato;
    typeof(obj.POD) a, b, c; // create POD type objects
    foreach (foo; [a, b, c])
        lista ~= obj.fromPOD(foo);

    assert(lista.length == 3);
}

private string[][2] getFields(T)()
{
    string[][2] members;
    static foreach (member; [__traits(allMembers, T)])
        static if (!isFunction!(__traits(getMember, T, member)))
            static if (member != "Monitor")
                {
                members[0] ~= typeof(__traits(getMember, T, member)).stringof;
                members[1] ~= member;
            }
    return members;

}

private auto generatePOD(T)()
{
    enum structName = toLower!string(T.stringof);
    mixin("struct %s { %s }".format(structName, generateFields!T));
    mixin(structName ~ " POD;");
    return POD;
}

private string generateFields(T)()
{
    enum fields = getFields!T;
    string output;
    static foreach (i, field; fields[0])
        output ~= "%s %s;".format(field, fields[1][i]);
    return output;
}

private string generateGet(T)()
{
    enum Fields = getFields!T;
    enum Case = "case \"%s\": return to!string(this.%s);";
    string output = "switch(memberName) {";
    static foreach (field; Fields[1])
        output ~= Case.format(field, field);
    return output ~ "default: return null;}";
}

private string generateSet(T)()
{
    enum Fields = getFields!T;
    enum Case = "case \"%s\": this.%s = to!%s(memberValue); break;";
    string output = "switch(memberName) {";
    static foreach (i, field; Fields[1])
        output ~= Case.format(field, field, Fields[0][i]);
    return output ~ "default: break;}";
}
