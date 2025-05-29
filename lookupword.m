function str=lookupword(word)
word=urlencode(word);  % ÏÈ¸øµ¥´Ê±àÂë
website=['http://fanyi.youdao.com/openapi.do?keyfrom=cxvsdffd33&key=1310976914&type=data&doctype=xml&version=1.1&q=' word '&only=translate" '];
[sourcefile status]=urlread(website);
expr1='<explains>';
expr2='</explains>';
aa=strfind(sourcefile,expr1)+11;
bb=strfind(sourcefile,expr2)-1;
str=sourcefile(aa:bb);
str=strrep(str,'<ex><![CDATA[','');
str=strrep(str,']]></ex>','');
str=strrep(str,'  ','');
str=strtrim(str);
end