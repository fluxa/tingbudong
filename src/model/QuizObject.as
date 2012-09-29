package model
{
	import mx.events.IndexChangedEvent;
	
	public class QuizObject extends Object
	{
		import helpers.Memory;
		
		public var quiz1Status:int;
		public var quiz2Status:int;
		public var quiz3Status:int;
		public var quiz4Status:int;
		public var quiz5Status:int;
		
		public var myVocab:Vocab;
		public function QuizObject(vcb:Vocab)
		{
			super();
			this.myVocab = vcb;
		}
		
		public function reset():void{
			
			quiz1Status = 0;
			quiz2Status = 0;
			quiz3Status = 0;
			quiz4Status = 0;
			quiz5Status = 0;
		}
		public function setQuized(type:int, mastered:Boolean, countHanzi:Boolean, time:Number):void{
			
			if(myVocab is Grammar) return;
			var val:int = (mastered)?1:0;
			
			switch(type){
				
				case 1:
					quiz1Status = val;
					break;
				case 2:	
					quiz2Status = val;
					break;
				case 3: 
					quiz3Status = val;
					break;
				case 4:
					quiz4Status = val;
					break;
				default:
					break;
				
				
			}
			Memory.didPracticeWord(myVocab as Word, mastered, time);
		}
		public function sentenceQuized(mastered:Boolean):void{
			if(myVocab is Word) return;
			quiz5Status = (mastered)?1:0;				
			Memory.didPracticeGrammar(myVocab as Grammar, true);
		}
	}
}