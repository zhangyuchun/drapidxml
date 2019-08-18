import rapidxml;
import std.stdio;

void test1()
{
	xml_document doc = new xml_document;
	string doc_text = "<single-element/>";
	doc.parse!(0)(doc_text);
	auto node = doc.first_node();
	assert(node.m_name == "single-element");
    //doc.validate();
}

void test2()
{   
    xml_document doc = new xml_document;
	string doc_text = "<pfx:single-element/>";
	doc.parse!(0)(doc_text);
	auto node = doc.first_node();
	//assert(node.m_name == "single-element");
    doc.validate();
}

void test3()
{
    xml_document doc = new xml_document;
	string doc_text = "<single-element attr='one' attr=\"two\"/>";
	doc.parse!(0)(doc_text);
	auto node = doc.first_node();
	assert(node.m_name == "single-element");
    doc.validate();
}

int main()
{
    test1();
    test2();
    test3();
    return 0;
}
