<%
// written by Soroush Dalili (@irsdl)
// Simple multiline plain/text to Form Key/Value converter!
if(System.Web.HttpContext.Current.Request.Form.Count == 0 && System.Web.HttpContext.Current.Request.ContentType=="text/plain"){
	var bodyString = "";
	using (System.IO.StreamReader reader = new System.IO.StreamReader(System.Web.HttpContext.Current.Request.InputStream, Encoding.UTF8))
	{
		bodyString = reader.ReadToEnd();
	}

	string[] result = System.Text.RegularExpressions.Regex.Split(bodyString, @"(?<parser>[^\r\n=]{1,50}=[^\r\n]*([\r\n]+[^\r\n=]+)*)(?=[\r\n])", System.Text.RegularExpressions.RegexOptions.Multiline|System.Text.RegularExpressions.RegexOptions.ExplicitCapture, System.TimeSpan.FromMilliseconds(500));

	var oForm = System.Web.HttpContext.Current.Request.Form;
	var flags = System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance;
	oForm = (NameValueCollection) System.Web.HttpContext.Current.Request.GetType().GetField("_form", flags).GetValue(System.Web.HttpContext.Current.Request);
	var oReadable = oForm.GetType().GetProperty("IsReadOnly", flags);
	oReadable.SetValue(oForm, false, null);

	foreach (string match in result)
	{
		if(!String.IsNullOrWhiteSpace(match)){
			var keyValue = match.Split(new char[] { '=' },2);
			var key = keyValue[0];
			if(!String.IsNullOrWhiteSpace(key)){
				var value = "";
				if(keyValue.Length > 1)
					value =  keyValue[1];
				
				oForm[key] = value;
				//System.Web.HttpContext.Current.Response.Write(key+"="+value+"&");
			}
		}
	}

	oReadable.SetValue(oForm, true, null);
	
	var oContentType = System.Web.HttpContext.Current.Request.GetType().GetField("_contentType", flags);
	oContentType.SetValue(System.Web.HttpContext.Current.Request, "application/x-www-form-urlencoded");
	
	System.Web.HttpContext.Current.Response.Clear();
    System.Web.HttpContext.Current.Response.BufferOutput = true;
	Server.Transfer(System.Web.HttpContext.Current.Request.Path, true);
	System.Web.HttpContext.Current.Response.End();

}
%>