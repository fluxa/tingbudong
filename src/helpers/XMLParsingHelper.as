package helpers
{
	import model.Layout;
	import model.Session;
	import model.Vocab;
	import model.Word;
	
	import mx.events.IndexChangedEvent;

	public class XMLParsingHelper
	{
		public static var IKNOWTHESE:Number 	= 1;
		public static var ALMOST:Number 		= 2;
		public static var ALITTLE:Number 		= 3;
		public static var WHATSTHAT:Number 		= 4;
		public static var NOIDEA:Number 		= 5;
		
		public function XMLParsingHelper()
		{ 
		}
		private static function getTitle(type:int, category:int):String{
			
			switch(category){
				case IKNOWTHESE:
					return (type == Vocab.LONG_TERM_KNOWLEDGE)? Layout.LONGTERM_TXT : Layout.IKNOWTHESE_TXT;
				case ALMOST:
					return (type == Vocab.LONG_TERM_KNOWLEDGE)? Layout.MIDTERM_TXT : Layout.ALMOST_TXT;
				case ALITTLE:
					return (type == Vocab.LONG_TERM_KNOWLEDGE)? Layout.SHORTTERM_TEXT : Layout.ALITTLE_TXT;
				case WHATSTHAT:
					return (type == Vocab.LONG_TERM_KNOWLEDGE)? Layout.TOMORROW_TXT : Layout.WHATSTHAT_TXT;
				case NOIDEA:
					return (type == Vocab.LONG_TERM_KNOWLEDGE)? Layout.NOIDEA_TXT : Layout.NOIDEA_TXT;
				default:
					return "";
			
			}
		return "";
		}
		public static function getVocabXML(type:int, words:Array):String{
			var arr:Array = DatabaseHelper.getInstance().getAllWords();
			
			if(arr.length == 0)return "";
			var str:String = 	"<category name='"+getTitle(type,IKNOWTHESE)+"' count='"	+getAllForWords(IKNOWTHESE, words, type)+"' />" +
								"<category name='"+getTitle(type,ALMOST) 	+"' count='"	+getAllForWords(ALMOST, words, type)+"' />" +
								"<category name='"+getTitle(type,ALITTLE) 	+"' count='"	+getAllForWords(ALITTLE, words, type)+"' />" +
								"<category name='"+getTitle(type,WHATSTHAT) +"' count='"	+getAllForWords(WHATSTHAT, words, type)+"' />" +
								"<category name='"+getTitle(type,NOIDEA) 	+"' count='"	+getAllForWords(NOIDEA, words, type)+"' />";
			trace(str);
			return  str;
		}
		public static function getSessionXML():String{
			var string:String = "";
			var sessions:Array = DatabaseHelper.getInstance().getSessions();
			
			var type:int = Vocab.LONG_TERM_KNOWLEDGE;
			var len:int = sessions.length;
			for(var i:int = 0; i<len; i++){
				var session:Session = sessions[i] as Session;
				if(session.words.length == 0)
					continue;
				var str:String = "<item name='"+session.name+"'>"+
					"<knowledge category='1' count='"+getAllForCategory(IKNOWTHESE, type, 	session.id)+"'/>" + 
					"<knowledge category='2' count='"+getAllForCategory(ALMOST, type, 		session.id)+"'/>" +
					"<knowledge category='3' count='"+getAllForCategory(ALITTLE, type, 		session.id)+"'/>" +
					"<knowledge category='4' count='"+getAllForCategory(WHATSTHAT, type, 	session.id)+"'/>" +
					"<knowledge category='5' count='"+getAllForCategory(NOIDEA, type,		session.id)+"'/>" +
					"</item>";
				string = string.concat(str);
			}
				return string;
		}
		public static function getTagXML():String{
			var string:String = "";
			var tags:Array = DatabaseHelper.getInstance().getTags()
			var type:int = Vocab.LONG_TERM_KNOWLEDGE;
			for(var i:int = 0; i<tags.length; i++){
				var tag:String = tags[i];
				var wrds:Array = DatabaseHelper.getInstance().getWordsWithTags(new Array(tag));
				var str:String = "<item name='"+tag+"'>"+
				"<knowledge category='1' count='"+getAllForWords(IKNOWTHESE, 	wrds, type)+"'/>" + 
				"<knowledge category='2' count='"+getAllForWords(ALMOST, 		wrds, type)+"'/>" +
				"<knowledge category='3' count='"+getAllForWords(ALITTLE, 		wrds, type)+"'/>" +
				"<knowledge category='4' count='"+getAllForWords(WHATSTHAT, 	wrds, type)+"'/>" +
				"<knowledge category='5' count='"+getAllForWords(NOIDEA, 		wrds, type)+"'/>" +
				"</item>";
				string = string.concat(str);
			}
			return string;
			//return "<category name='I know these' count='51' /><category name='almost' count='12' /><category name='a little' count='5' /><category name='whats that' count='2' /><category name='no idea' count='22' />";
		}
		public static function getAllForCategory(category:int,type:int, sessionid:Number = -1):Number{

			if(sessionid == -1){
				return getAllForWords(category,DatabaseHelper.getInstance().getAllWords(), type);
			}else{
				var session:Session = DatabaseHelper.getInstance().getSession(sessionid);
				return getAllForWords(category,session.words, type);
			}
		
		}
		public static function getAllForWords(category:int,words:Array, type:int):Number{
		
			var count:Number = 0;
			for(var i:int = 0; i<words.length; i++){
				var wrd:Vocab = words[i];
				var perc:Number = wrd.getPercentage(type);
				switch(category){
					case IKNOWTHESE:
						if(perc <= 100 && perc > 90) count++;
						break;
					case ALMOST:
						if(perc <= 90 && perc >= 60) count++;
						break;
					case ALITTLE:
						if(perc < 60 && perc >= 40) count++;
						break;
					case WHATSTHAT:
						if(perc < 40 && perc >= 20) count++;
						break;
					case NOIDEA:
						if(perc < 20 && perc >= 0) count++;
						break;
					default:
						break;
				}
			}
			return count;
		}
	}
}