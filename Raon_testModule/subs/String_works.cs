
using System.Collections;

public class StringUtilss  {


	public string [] get_divided_strs (string str, string indicator)
	{
		// indicator can be _ / - . or something
        if (str.IndexOf(indicator,System.StringComparison.Ordinal) == -1)
        {
            return null;
        }

		ArrayList outlist = new ArrayList();
		str = str.Trim();

		while(true)
		{
			int index = str.IndexOf(indicator, System.StringComparison.Ordinal);

			if(index == -1) 
			{
				outlist.Add(str);
				break;
			}

			string value = str.Substring(0,index);

			outlist.Add(value);

			str = str.Substring(index+1);
			str = str.Trim();
		}

		// array to string[]
		string [] str_arrays = new string[outlist.Count];
		for(int i=0; i<str_arrays.Length; i++)
		{
			str_arrays[i] = outlist[i].ToString();
		}

		return str_arrays;
	}

    public ArrayList stringArray_to_arrayList (string [] strs)
    {
        ArrayList out_arrayList = new ArrayList();

        for(int i=0; i<strs.Length; i++)
        {
            out_arrayList.Add(strs[i]);
        }

        return out_arrayList;
    }

    public string [] Arraylist_to_stringArray (ArrayList in_list)
    {
        string[] out_strs = new string[in_list.Count];

        for(int i =0; i<in_list.Count; i++)
        {
            out_strs[i] = in_list[i].ToString();
        }

        return out_strs;
    }
}
