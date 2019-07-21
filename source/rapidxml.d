module rapidxml;

import skip;

enum node_type
{
	node_document,      //!< A document node. Name and value are empty.
	node_element,       //!< An element node. Name contains element name. Value contains text of first data node.
	node_data,          //!< A data node. Name is empty. Value contains data text.
	node_cdata,         //!< A CDATA node. Name is empty. Value contains data text.
	node_comment,       //!< A comment node. Name is empty. Value contains comment text.
	node_declaration,   //!< A declaration node. Name and value are empty. Declaration parameters (version, encoding and standalone) are in node attributes.
	node_doctype,       //!< A DOCTYPE node. Name is empty. Value contains DOCTYPE text.
	node_pi,            //!< A PI node. Name contains target. Value contains instructions.
	node_literal        //!< Value is unencoded text (used for inserting pre-rendered XML).
};

 // Parsing flags
 const int parse_no_data_nodes = 0x1;

const int parse_no_element_values = 0x2;

const int parse_no_string_terminators = 0x4;

const int parse_no_entity_translation = 0x8;

const int parse_no_utf8 = 0x10;

const int parse_declaration_node = 0x20;

const int parse_comment_nodes = 0x40;

const int parse_doctype_node = 0x80;

const int parse_pi_nodes = 0x100;

const int parse_validate_closing_tags = 0x200;

const int parse_trim_whitespace = 0x400;

const int parse_normalize_whitespace = 0x800;

const int parse_open_only = 0x1000;

const int parse_parse_one = 0x2000;

const int parse_validate_xmlns = 0x4000;

const int parse_default = 0;

const int parse_non_destructive = parse_no_string_terminators | parse_no_entity_translation;

const int parse_fastest = parse_non_destructive | parse_no_data_nodes;

const int parse_full = parse_declaration_node | parse_comment_nodes | parse_doctype_node | parse_pi_nodes | parse_validate_closing_tags;

 

class xml_base
{
	string m_name;
	string m_value;
	xml_base m_parent;

}

class xml_attribute : public xml_base
{


	xml_attribute m_prev_attribute;
	xml_attribute m_next_attribute;
	string	m_xmlns;
	string  m_local_name;
}

class xml_node: public xml_base
{

	string m_prefix;
	string m_xmlns;
	node_type m_type;
	xml_node m_first_node;
	xml_node m_last_node;
	xml_attribute m_first_attribute;
	xml_attribute m_last_attribute;
	xml_node m_pre_sibling;
	xml_node m_next_sibling;
	string m_contents;

	xml_node first_node(string name = null , string xmlns = null , bool case_sensitive = true)
	{
		for(xml_node child = m_first_node ; child ; child = child.m_next_sibling)
		{
			if((!name || child.m_name == name) && (!xmlns || child.m_xmlns == xmlns)
				return child;
		}
		return null;
	}

	xml_node last_node(string name = null , string xmlns = null , bool case_sensitive = true)
	{
		for(xml_node child = m_last_node ; child ; child = child.m_prev_sibling)
		{
			if((!name || child.m_name == name) && (!xmlns || child.m_xmlns == xmlns)
				return child;
		}
		return null;
	}


	void prepend_node(xml_node child)
	{
		if(fisrt_node())
		{
			child.m_next_sibling = m_first_node;
			m_first_node.m_pre_sibling = child;
		}
		else
		{
			child.m_next_sibling = null;
			m_last_node = child;
		}

		m_first_node = child;
		child.m_parent = this;
		child.m_pre_sibling = null;
	}

	void append_node(xml_node child)
	{
		if(fisrt_node())
		{
			child.m_pre_sibling = m_last_node;
			m_last_node.m_next_sibling = child;
		}
		else
		{
			child.m_pre_sibling = null;
			m_first_node = child;
		}
		m_last_node = child;
		child.m_parent = this;
		child.m_next_sibling = null;
	}

	void insert_node(xml_node where , xml_node child)
	{
		if(where == m_first_node)
			prepend_node(child);
		else if(where == null)
			append_node(child);
		else
		{
			child.m_pre_sibling = where.m_pre_sibling;
			chid.m_next_sibling = where;
			where.m_pre_sibling.m_next_sibling = chid;
			where.m_pre_sibling = child;
			child.m_parent = this;
		}

	}

	void remove_first_node()
	{
		xml_node child = m_first_node;
		m_first_node = chid.m_next_sibling;
		if(child.m_next_sibling)
			child.m_next_sibling.m_pre_sibling = null;
		else
			m_last_node = null;
		child.m_parent = null;
	}

	void remove_last_node()
	{
		xml_node child = m_last_node;
		if(child.m_pre_sibling)
		{
			m_last_node = child.m_pre_sibling;
			child.m_pre_sibling.m_next_sibling = null;
		}
		else
		{
			m_first_node = null;
		}

		child.m_parent = null;
	}



	void remove_node(xml_node where)
	{
		if(where == m_first_node)
			remove_first_node();
		else if(where == m_last_node)
			remove_last_node();
		else
		{
			where.m_pre_sibling.m_next_sibling = where.m_next_sibling;
			where.m_next_sibling.m_pre_sibling = where.m_pre_sibling;
			where.m_parent = null;
		}
	}

	void remove_all_nodes()
	{
		for( xml_node node = first_node(); node; node = node.m_next_attribute)
			node.m_parent = null;
		
		m_first_node = null;
	}


	xml_attribute first_attribute(string name = null , bool case_sensitive = true)
	{
		if(name)
		{
			for(xml_attribute attribute = m_first_attribute ; attribute ; attribute = attribute.m_next_attribute)
			{
				if(attribute.m_name == name)
					return attribute;
			}
			return null;
		}
		else
		{
			return m_first_attribute;
		}
	}

	xml_attribute last_attribute(string name = null , bool case_sensitive = true)
	{
		if(name)
		{
			for(xml_attribute attribute = m_last_attribute ; attribute ; attribute = attribute.m_last_attribute)
			{
				if(attribute.m_name == name)
					return attribute;
			}
			return null;
		}
		else
		{
			return m_last_attribute;
		}
	}

	void prepend_attribute(xml_attribute attribute)
	{
		if(first_attribute())
		{
			attribute.m_next_attribute = m_first_attribute;
			m_first_attribute.m_prev_attribute = attribute;
		}
		else
		{
			attribute.m_next_attribute = this;
			m_last_attribute = attribute;
		}
		m_first_attribute = attribute;
		attribute.m_parent = this;
		attribute.m_prev_attribute = null;
	}

	void append_attribute(xml_attribute attribute)
	{
		if(first_attribute())
		{
			attribute.m_prev_attribute = m_last_attribute;
			m_last_attribute.m_next_attribute = attribute;
		}
		else
		{
			attribute.m_prev_attribute = null;
			m_first_attribute = attribute;
		}

		m_last_attribute = attribute;
		attribute.m_parent = this;
		attribute.m_next_attribute = null;
	}

	void insert_attribute(xml_attribute where , xml_attribute attribute)
	{
		if(where == m_first_attribute)
			prepend_attribute(attribute);
		else if(where == null)
			append_attribute(attribute);
		else
		{
			attribute.m_prev_attribute = where.m_prev_attribute;
			attribute.m_next_attribute = where;
			where.m_prev_attribute.m_next_attribute = attribute;
			where.m_prev_attribute = attribute;
			attribute.m_parent = this;
		}
	}

	void remove_first_attribute()
	{
		xml_attribute attribute = m_first_attribute;
		if(attribute.m_next_attribute)
		{
			attribute.m_next_attribute.m_prev_attribute = null;
		}
		else
		{
			m_last_attribute = null;
		}

		attribute.m_parent = null;
		m_first_attribute = attribute.m_next_attribute;
	}

	void remove_last_attribute()
	{
		xml_attribute attribute = m_last_attribute;
		if(attribute.m_prev_attribute)
		{
			attribute.m_prev_attribute.m_next_attribute = null;
			m_last_attribute = attribute.m_prev_attribute;
		}
		else
			m_first_attribute = null;

		attribute.m_parent = null;
	}

	void remove_attribute(xml_attribute where)
	{
		if(where == m_first_attribute)
			remove_first_attribute();
		else if(where == m_last_attribute)
			remove_last_attribute();
		else
		{
			where.m_prev_attribute.m_next_attribute = where.m_next_attribute;
			where.m_next_attribute.m_prev_attribute = where.m_prev_attribute;
			where.m_parent = null;
		}
	}

	void remove_all_attributes()
	{
		for(xml_attribute attribute = first_attribute() ; attribute ; attribute = attribute.m_next_attribute)
		{
			attribute.m_parent = null;
		}
		m_first_attribute = null;
	}

	void validate()
	{
		if(m_xmlns == null)
		{	
			writeln("Element XMLNS unbound");
			return;
		}
		for(xml_node child = first_node(); child ; child = child.m_next_sibling)
			child.validate();

		for(xml_attribute attribute = first_attribute() ; attribute ; attribute = attribute.m_next_attribute)
		{
			if(attribute.m_xmlns == null)
			{	
				writeln("Attribute XMLNS unbound");
				return;
			}
			for(xml_attribute otherattr = first_attribute() ; otherattr != attribute; otherattr = otherattr.m_next_attribute)
			{	
				if(attribute.m_name == otherattr.m_name)
				{	
					writeln("Attribute doubled");
					return;
				}
				if(attribute.m_xmlns == otherattr.m_xmlns && attribute.m_local_name == otherattr.m_local_name)
				{
					writeln("Attribute XMLNS doubled");
					return;
				}
			}

		}
	}
}





class xml_document : public xml_node
{
	string parse(int Flags)(string text , xml_document parent = null)
	{
		this->remove_all_nodes();
		this->remove_all_attributes();
		this->m_parent = parent ? parent->m_first_node : null;

		parse_bom(text);

		int index = 0;
		int length = text.length;
		while(1)
		{
			skip(whitespace_pred)(text); 
			if(index == length)
				break;
			if(text[index] =='<')
			{
				++index;
				xml_node = par
			}
		}

		return string.init;
	}

	xml_node parse_node(ref string text)
	{
		switch(text[0])
		{
			default:
				return par
		}
	}

	xml_node parse_element(int Flags)(ref string text)
	{
		xml_node element = new xml_node();
		string prefix = text;
		//skip element_name_pred
		skip(element_name_pred)(text);

		if(text == prefix)
			writeln("expected element name or prefix", text);
		if(text[index] == ':')
		{
			element.m_prefix = prefix[0 .. prefix.length - text.length].dup;
			text = text[1 .. $ -1];
			string name = text;
			//skip node_name_pred
			skip(node_name_pred)(text);
			if(text == name)
				writeln("expected element local name", text);
			element.m_name = name[0 .. name.length - text.length].dup;
		}
		else{
			element.m_name = prefix[ 0 .. prefix.length - text.length].dup;			
		}

		//skip whitespace_pred
		skip(whitespace_pred)(text);
		parse_node_attributes(text , element);

		if(text[0] == '>')
		{
			text = text[1 : $-1];
			string contents = text;
			string contents_end = null;
			if(!(Flags & parse_open_only))
				contents_end = parse_node
		}



	}

	string parse_node_contents(ref string text , xml_node node)
	{
		string retval;
		
		while(1)
		{
			string contents_start = text;
			skip(whitespace_pred)(text);
			char next_char = text[0];

after_data_node:

			switch(next_char)
			{
				case '<':
				if(text[1] == '/')
				{
					retval = text;
					text = text[2 .. $ - 1];
					if(Flags & parse_validate_closing_tags)
					{
						string closing_name = text;
						skip(node_name_pred)(text);
						if(closing_name == node.m_name)
							writeln("invalid closing tag name", text);
					}
					else
					{
						skip(node_name_pred)(text);
					}

					skip(whitespace_pred)(text);
					if(text[0] != '>')
						writeln("expected >", text);
					text = text[1 .. $- 1];
					if(Flags & parse_open_only)
						writeln("Unclosed element actually closed.", text);
					
					return retval;
				}
				else
				{
					text = text[1 .. $ - 1];
					if(xml_node child = parse_node(Flags & ~parse_open_only)(text))
						node.append_node(child);
				}

				
			}
		}
	}

	void parse_node_attributes(int Flags)(ref string text , xml_node node)
	{
		int index = 0;
		while(attribute_name_pred.test(text[0]))
		{
			string name = text;
			text = text[1 .. $ -1];
			skip(attribute_name_pred)(text);
			if(text == name)
				writeln("expected attribute name", name);

			xml_attribute *attribute = new xml_attribute();
			attribute.m_name = name[0 .. name.length - text.length];
			node.append_attribute(attribute);

			skip(whitespace_pred)(text);

			if(text[0] != '=')
				writeln("expected =", text);
			
			text = text[1 .. $ - 1];

			skip(whitespace_pred)(text);

			char quote = text[0];
			if(quote != "\'" && quote != "\"")
				writeln("expected ' or \"", text);
			
			text = text[1 .. $ - 1];
			string value = text ;
			string end;
			const int AttFlags = Flags & ~parse_normalize_whitespace;
			/*if(quote == "\'")
				end = skip_and_expand_character_refs
			else
				end = skip_and_expand_character_refs*/
			
			attribute.m_value = value[0 .. value.length - end.length];

			if(text[0] != quote)
				writeln("expected ' or \"", text);
			
			text = text[1 .. $ - 1];

			skip(whitespace_pred)(text);

		}
	}



	
	static void skip(ref string text)
	{
		
	}

	void parse_bom(ref string text)
	{
		if(text[0] == 0xEF 
		&& text[1] == 0xBB 
		&& text[2] == 0xBF)
		{
			text = text[3 .. $ - 1];
		}
	}


	

}



int main()
{
	return 0;
}