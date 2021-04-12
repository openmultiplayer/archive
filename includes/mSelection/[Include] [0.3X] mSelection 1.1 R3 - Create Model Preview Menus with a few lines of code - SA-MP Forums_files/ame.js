function ame_toggle_view(obj)
{
	e = fetch_tags(document, 'div');
	
	for (i = 0; i < e.length; i++)
	{
		if (e[i].id.substr(0,4) == "ame_")
		{
			parts = e[i].id.split("_");
			zone = parts[2];
			
			if (parts[1] == 'noshow')
			{
				display = (obj[zone] == 'true' ? 'none' : 'inline');
				e[i].style.display = display;
			}
			else if (parts[1] == 'doshow')
			{
				display = (obj[zone] == 'true' ? 'inline' : 'none');
				e[i].style.display = display;				
			}			
		}
	}
}