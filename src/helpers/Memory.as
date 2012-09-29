package helpers
{
	import flash.events.Event;
	import flash.media.Video;
	
	import model.Grammar;
	import model.Vocab;
	import model.Word;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.controls.Alert;
	import mx.core.Application;

	
	public class Memory extends Object
	{
		public static var THRESHHOLD:int = 90;
		private static var DECAY_VALUES:Array = [0.6, //short term
												0.9,// forgotten tomorrow
												0.9486832980505138,//short term
												0.9791483623609768,//mid term
												0.9850612054411155, //mid term
												0.9947458259305311,//long term
												0.9982455322867291,//long term
												0.9994148350777138,//long term
												0.9998049069670882]; //long term
		
		
		public function Memory()
		{
			super();
		}
		
		public static function onAppStart(today:Date, lastopeneddate:Date):void{
		trace(today+" //  "+lastopeneddate);
			var days:int = getDaysBetweenDates(lastopeneddate,today);
				
				//go through all words 
				var allwords:Array = DatabaseHelper.getInstance().getAllWords();
				var allGrammar:Array = DatabaseHelper.getInstance().getAllGrammar();
				allwords = allwords.concat(allGrammar);
				for(var i:int=0; i<allwords.length;i++){
					var w:Vocab = allwords[i];
					
					//update knowledge
					overTime(days, w);	
					
					w._ripe = (w.knowledge <=THRESHHOLD);
					if(w is Word) DatabaseHelper.updateWord(w as Word);
					else DatabaseHelper.updateGrammar(w as Grammar);
				}
			}
		public static function didPracticeGrammar(grammar:Grammar, correct:Boolean):void{
		
			grammar.rec.recordResults(correct);
			
			if(correct){
				
				grammar.old_k = grammar.knowledge; 
				
				//TODO: adjust and compare to actual knowledge
				grammar.knowledge +=25;
				if(grammar.knowledge > 100)grammar.knowledge=100;
				
				//check if decay rate has changed
				checkDecayRate(grammar);
			}
			
			//save word to db
			DatabaseHelper.updateGrammar(grammar);
		
		}
		public static function didPracticeWord(word:Word, correct:Boolean, time:Number):void
		{
			
			word.rec.recordResults(correct, time);

			if(correct){
				
				word.old_k = word.knowledge; 
				
				//TODO: adjust and compare to actual knowledge
				word.knowledge +=25;
				if(word.knowledge > 100)word.knowledge=100;
				
				//check if decay rate has changed
				checkDecayRate(word);
			}
			
			//save word to db
		  	DatabaseHelper.updateWord(word);
		}
		private static function checkDecayRate(word:Vocab):void{
			trace(word.old_k+" <="+ THRESHHOLD +" && "+ word.knowledge +" > "+THRESHHOLD);
			if (word.old_k <= THRESHHOLD && word.knowledge>THRESHHOLD) {
				word.decayRate_index = (word.decayRate_index >=DECAY_VALUES.length-1)? DECAY_VALUES.length-1 : word.decayRate_index+1;
			}
			trace(word.decayRate_index );
		}
		private static function overTime(days:int, w:Vocab):void{
			var decayRate:Number = DECAY_VALUES[w.decayRate_index];
			if(w.knowledge == 0)return;
			for(var i:int=0;i<days;i++){
				w.knowledge *= decayRate;
			}
			
		}
		private static function getDaysBetweenDates(date1:Date,date2:Date):int
		{
			var one_day:Number = 1000 * 60 * 60 * 24
			var date1_ms:Number = date1.getTime();
			var date2_ms:Number = date2.getTime();
			var difference_ms:Number = Math.abs(date1_ms - date2_ms)
			return Math.round(difference_ms/one_day);
		}
		
		/*public static function sortArray(arr:Array):Array
		{
			//set up array of items, we will remove 1 at a time
			var items:ArrayCollection = new ArrayCollection(arr);
			
			var PROB_PILES:Array = new Array(500, 200, 100, 50, 20, 10, 5, 2);
			var PROB_PILES_FOR_FIRST_FIVE:Array = new Array(100, 200, 300, 200, 100, 50, 20, 10);
			
			var picker:ArrayCollection = new ArrayCollection();
			
			while(items.length >0)
			{
				var PROBABILITIES:Array = (picker.length<5)?PROB_PILES_FOR_FIRST_FIVE:PROB_PILES;
			
				//find piles with words in them
				var possiblePiles:ArrayCollection = new ArrayCollection();
				for each(var w:Word in items)
				{
					if(!(possiblePiles.contains(w.leitnerCurrentPile)))
					{
						possiblePiles.addItem(w.leitnerCurrentPile);
					}
				}
				
				//find total prob of those piles
				var totalc:int = 0;
				for each(var pile:int in possiblePiles)
				{
					var c:int = PROBABILITIES[pile];
					totalc += c;
				}
				
				//pick a random pile from those piles
				var p:Number = prob()*totalc;
				var total:int = 0;
				pileNo = 0;
				
				for each(var pile2:int in possiblePiles)
				{
					pileNo = pile2;
					total += PROBABILITIES[pileNo];
					if(total >p){
						break;
					}
				
				}
				
				//now pick from the pile with number pileNo
				var wordsInPile:ArrayCollection = new ArrayCollection(items.source);
				wordsInPile.filterFunction = wordfilterfunction;
				wordsInPile.refresh();
				
				var leitnerSort:Sort = new Sort();
					leitnerSort.compareFunction = sortByLeitnerOrder;
				
				wordsInPile.sort = leitnerSort;
				wordsInPile.refresh();
				
				var word:Word = wordsInPile.getItemAt(0) as Word;
					
				picker.addItem(word);
				items.removeItemAt(items.getItemIndex(word));
			}
		
			return picker.toArray();
		
		}*/
		
		
		
		

		
	
		/* returns a number between 0 and 1*/
		private static function prob():Number {
			return Math.random();
		}
		
		private function randomElement(arr:Array):int {
			return Math.random() % arr.length;
			
		}
		
		/*
		
		private static function wordfilterfunction(obj:Word):Boolean {
		// return whether or not the current bandAryCol index meets the filter criteria
		return (obj.leitnerCurrentPile == pileNo);
		}
		private static function sortByLeitnerOrder(a:Object, b:Object, fields:Array = null):int
		{
			var diff:int = Word(a).leitnerOrder - Word(b).leitnerOrder;
			if (diff==0) {
				return 0;
			} else if (diff>0) {
				return -1;
			} else {
				return 1;
			}
		}*/
	
	
	}
}