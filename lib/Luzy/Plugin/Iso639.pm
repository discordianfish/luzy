package Luzy::Plugin::Iso639;
use base 'Luzy::Plugin';

use Encode;

sub register {
	my ($self, $app, $conf) = @_;
	
	my @codes = ();
	
	binmode DATA, ":encoding(utf-8)";
	while(my $data = <DATA>) {
		chomp $data;
		
		my @data = split /\t/, $data; # decode('UTF-8', $data);
		push @codes, {
			name => $data[0],
			native_name => $data[1],
			code => $data[2],
		};
	}
	
	$app->renderer->add_helper( iso_639 => sub { \@codes } );
}


1;
__DATA__
Abkhaz	аҧсуа	ab
Afar	Afaraf	aa
Afrikaans	Afrikaans	af
Akan	Akan	ak
Albanian	Shqip	sq
Amharic	አማርኛ	am
Arabic	العربية	ar
Aragonese	Aragonés	an
Armenian	Հայերեն	hy
Assamese	অসমীয়া	as
Avaric	авар мацӀ, магӀарул мацӀ	av
Avestan	avesta	ae
Aymara	aymar aru	ay
Azerbaijani	azərbaycan dili	az
Bambara	bamanankan	bm
Bashkir	башҡорт теле	ba
Basque	euskara, euskera	eu
Belarusian	Беларуская	be
Bengali	বাংলা	bn
Bihari	भोजपुरी	bh
Bislama	Bislama	bi
Bosnian	bosanski jezik	bs
Breton	brezhoneg	br
Bulgarian	български език	bg
Burmese	ဗမာစာ	my
Catalan	Català	ca
Chamorro	Chamoru	ch
Chechen	нохчийн мотт	ce
Chichewa	chiCheŵa, chinyanja	ny
Chinese	中文 (Zhōngwén), 汉语, 漢語	zh
Chuvash	чӑваш чӗлхи	cv
Cornish	Kernewek	kw
Corsican	corsu, lingua corsa	co
Cree	ᓀᐦᐃᔭᐍᐏᐣ	cr
Croatian	hrvatski	hr
Czech	česky, čeština	cs
Danish	dansk	da
Divehi	ދިވެހި	dv
Dutch	Nederlands, Vlaams	nl
Dzongkha	རྫོང་ཁ	dz
English	English	en
Esperanto	Esperanto	eo
Estonian	eesti, eesti keel	et
Ewe	Eʋegbe	ee
Faroese	føroyskt	fo
Fijian	vosa Vakaviti	fj
Finnish	suomi, suomen kieli	fi
French	français, langue française	fr
Fula	Fulfulde, Pulaar, Pular	ff
Galician	Galego	gl
Georgian	ქართული	ka
German	Deutsch	de
Greek	Ελληνικά	el
Guaraní	Avañe'ẽ	gn
Gujarati	ગુજરાતી	gu
Haitian	Kreyòl ayisyen	ht
Hausa	Hausa, هَوُسَ	ha
Hebrew	עברית	he
Herero	Otjiherero	hz
Hindi	हिन्दी, हिंदी	hi
Hiri Motu	Hiri Motu	ho
Hungarian	Magyar	hu
Interlingua	Interlingua	ia
Indonesian	Bahasa Indonesia	id
Interlingue	Originally called Occidental; then Interlingue after WWII	ie
Irish	Gaeilge	ga
Igbo	Asụsụ Igbo	ig
Inupiaq	Iñupiaq, Iñupiatun	ik
Ido	Ido	io
Icelandic	Íslenska	is
Italian	Italiano	it
Inuktitut	ᐃᓄᒃᑎᑐᑦ	iu
Japanese	日本語 (にほんご／にっぽんご)	ja
Javanese	basa Jawa	jv
Kalaallisut	kalaallisut, kalaallit oqaasii	kl
Kannada	ಕನ್ನಡ	kn
Kanuri	Kanuri	kr
Kashmiri	कश्मीरी, كشميري‎	ks
Kazakh	Қазақ тілі	kk
Khmer	ភាសាខ្មែរ	km
Kikuyu	Gĩkũyũ	ki
Kinyarwanda	Ikinyarwanda	rw
Kirghiz	кыргыз тили	ky
Komi	коми кыв	kv
Kongo	KiKongo	kg
Korean	한국어 (韓國語), 조선말 (朝鮮語)	ko
Kurdish	Kurdî, كوردی‎	ku
Kwanyama	Kuanyama	kj
Latin	latine, lingua latina	la
Luxembourgish	Lëtzebuergesch	lb
Luganda	Luganda	lg
Limburgish	Limburgs	li
Lingala	Lingála	ln
Lao	ພາສາລາວ	lo
Lithuanian	lietuvių kalba	lt
Luba-Katanga		lu
Latvian	latviešu valoda	lv
Manx	Gaelg, Gailck	gv
Macedonian	македонски јазик	mk
Malagasy	Malagasy fiteny	mg
Malay	bahasa Melayu, بهاس ملايو‎	ms
Malayalam	മലയാളം	ml
Maltese	Malti	mt
Māori	te reo Māori	mi
Marathi (Marāṭhī)	मराठी	mr
Marshallese	Kajin M̧ajeļ	mh
Mongolian	монгол	mn
Nauru	Ekakairũ Naoero	na
Navajo	Diné bizaad, Dinékʼehǰí	nv
Norwegian Bokmål	Norsk bokmål	nb
North Ndebele	isiNdebele	nd
Nepali	नेपाली	ne
Ndonga	Owambo	ng
Norwegian Nynorsk	Norsk nynorsk	nn
Norwegian	Norsk	no
Nuosu	ꆈꌠ꒿ Nuosuhxop	ii
South Ndebele	isiNdebele	nr
Occitan	Occitan	oc
Ojibwe	ᐊᓂᔑᓈᐯᒧᐎᓐ	oj
Old Church Slavonic	ѩзыкъ словѣньскъ	cu
Oromo	Afaan Oromoo	om
Oriya	ଓଡ଼ିଆ	or
Ossetian	ирон æвзаг	os
Panjabi	ਪੰਜਾਬੀ, پنجابی‎	pa
Pāli	पाऴि	pi
Persian	فارسی	fa
Polish	polski	pl
Pashto	پښتو	ps
Portuguese	Português	pt
Quechua	Runa Simi, Kichwa	qu
Romansh	rumantsch grischun	rm
Kirundi	kiRundi	rn
Romanian	română	ro
Russian	русский язык	ru
Sanskrit (Saṁskṛta)	संस्कृतम्	sa
Sardinian	sardu	sc
Sindhi	सिन्धी, سنڌي، سندھی‎	sd
Northern Sami	Davvisámegiella	se
Samoan	gagana fa'a Samoa	sm
Sango	yângâ tî sängö	sg
Serbian	српски језик	sr
Scottish Gaelic	Gàidhlig	gd
Shona	chiShona	sn
Sinhala	සිංහල	si
Slovak	slovenčina	sk
Slovene	slovenščina	sl
Somali	Soomaaliga, af Soomaali	so
Southern Sotho	Sesotho	st
Spanish	español, castellano	es
Sundanese	Basa Sunda	su
Swahili	Kiswahili	sw
Swati	SiSwati	ss
Swedish	svenska	sv
Tamil	தமிழ்	ta
Telugu	తెలుగు	te
Tajik	тоҷикӣ, toğikī, تاجیکی‎	tg
Thai	ไทย	th
Tigrinya	ትግርኛ	ti
Tibetan Standard	བོད་ཡིག	bo
Turkmen	Türkmen, Түркмен	tk
Tagalog	Wikang Tagalog, ᜏᜒᜃᜅ᜔ ᜆᜄᜎᜓᜄ᜔	tl
Tswana	Setswana	tn
Tonga	faka Tonga	to
Turkish	Türkçe	tr
Tsonga	Xitsonga	ts
Tatar	татарча, tatarça, تاتارچا‎	tt
Twi	Twi	tw
Tahitian	Reo Tahiti	ty
Uighur	Uyƣurqə, ئۇيغۇرچە‎	ug
Ukrainian	українська	uk
Urdu	اردو	ur
Uzbek	O'zbek, Ўзбек, أۇزبېك‎	uz
Venda	Tshivenḓa	ve
Vietnamese	Tiếng Việt	vi
Volapük	Volapük	vo
Walloon	Walon	wa
Welsh	Cymraeg	cy
Wolof	Wollof	wo
Western Frisian	Frysk	fy
Xhosa	isiXhosa	xh
Yiddish	ייִדיש	yi
Yoruba	Yorùbá	yo
Zhuang	Saɯ cueŋƅ, Saw cuengh	za
Zulu	isiZulu	zu
