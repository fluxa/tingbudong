package model
{	
	import helpers.Memory;

	public class Vocab
	{
		//
		public static var LONG_TERM_KNOWLEDGE:int = 0;
		public static var CURRENT_KNOWLEDGE:int = 1;
		public static var CURRENT_RECOLLECTION:int = 2;
		
		//metadata
		public var groupid:int;
		public var id:int;
		public var tagArray:Array;
		
		//sentences
		public var sentences:Array;
		
		//quiz mettadata
		public var decayRate_index:int = 0;
		public var knowledge:Number = 0.0;
		public var old_k:Number = 0.0;
		
		
		public var rec:Recolection = new Recolection();
		public var _ripe:Boolean = true;
		public var quizObj:QuizObject;
		
		public function Vocab()
		{
			this.tagArray 	= new Array();
			this.quizObj 	= new QuizObject(this);
		}
		public function isRipe():Boolean{	
			return (this.knowledge <= Memory.THRESHHOLD);}
		
		public function getColor(type:int):String{
			
			var percentageRight:Number;
			
			if(type == LONG_TERM_KNOWLEDGE){
				if(this.decayRate_index == 0) return Layout.NOIDEA_CL;
				if(this.decayRate_index == 1) return Layout.WHATSTHAT_CL;
				if(this.decayRate_index == 2) return Layout.ALITTLE_CL;
				if(this.decayRate_index == 3 || this.decayRate_index == 4) return Layout.ALMOST_CL;
				if(this.decayRate_index > 5) return Layout.IKNOWTHESE_CL;
				
			}else if(type == CURRENT_KNOWLEDGE){
				percentageRight =this.knowledge;
				
			}else if(type == CURRENT_RECOLLECTION){
				percentageRight =this.rec.recolection_rate*100;
				if(percentageRight < 20) return Layout.NOIDEA_CL;//red
				if(percentageRight < 40) return Layout.WHATSTHAT_CL;//purple
				if(percentageRight < 60) return Layout.ALITTLE_CL;//blue
				if(percentageRight < 80) return Layout.ALMOST_CL;//green
				if(percentageRight <= 100) return Layout.IKNOWTHESE_CL;//green
			}	
			
			return "#12d503";
		}
		//TODO test this
		public function getPercentage(type:int):Number{
			if(type == LONG_TERM_KNOWLEDGE){
				if(this.decayRate_index == 0) return 0;
				if(this.decayRate_index == 1) return 25;
				if(this.decayRate_index == 2) return 50;
				if(this.decayRate_index == 3 || this.decayRate_index == 4) return 75;
				if(this.decayRate_index > 5) return 100;
			}
			if(type == CURRENT_KNOWLEDGE) return this.knowledge;
			if(type == CURRENT_RECOLLECTION) return this.rec.recolection_rate*100;
			
			return 0;
		}
		public function settagArray(txt:String):void{
			
			if(txt == null){
				this.tagArray = new Array();
				return;
			}
			txt = txt.toLocaleLowerCase();
			var myPattern:RegExp = / /g;  
			txt = txt.replace(myPattern, "");
			this.tagArray = txt.split(",",20);
		}
		
		public function gettagArray():String{
			if(tagArray == null || tagArray.length == 0)
				return null;
			return tagArray.join(",");
			
		}
	}
}