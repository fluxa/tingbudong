package helpers
{
	import flash.events.Event;
	
	import model.Word;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.controls.Alert;
	import mx.core.Application;

	
	public class Leitner extends Object
	{
		
		public static var NUM_PILES:int = 5;
		private static var pileNo:int = 0;
		public function Leitner()
		{
			super();
		}
		
		public static function getNextDeadline(pile:int):Date{
			var today:Date = new Date();
			
			switch(pile){
				
				case 0:
					//should always be availble == today
					return new Date();
					break;
				case 1:	
					return new Date(today.fullYear, today.month, today.date+1);
					break;
				case 2:
					return new Date(today.fullYear, today.month, today.date+4);
					break;
				case 3:
					return new Date(today.fullYear, today.month, today.date+12);
					break;
				case 4:
					return new Date(today.fullYear, today.month, today.date+40);
					break;
				case 5:
					return new Date(today.fullYear, today.month, today.date+90);
					break;
				default:
					return new Date();
			}
		}
		public static function getEarliestDate(pile:int, deadline:Date):Date{
		
			switch(pile){
				
				case 0:
					//should always be availble == today
					return new Date();
					break;
				case 1:
					return new Date(deadline.getDate());
					break;
				case 2:
					return new Date(deadline.getDate()-1);
					break;
				case 3:
					return new Date(deadline.getDate()-2);
					break;
				case 4:
					return new Date(deadline.getDate()-3);
					break;
				case 5:
					return new Date(deadline.getDate()-4);
					break;
				default:
					return new Date();
			}
		}
		public static function getLatestDate(pile:int, deadline:Date):Date{
			switch(pile){
				
				case 0:
					//should always be availble == today
					return new Date();
					break;
				case 1:
					return new Date(deadline.getDate());
					break;
				case 2:
					return new Date(deadline.getDate()+1);
					break;
				case 3:
					return new Date(deadline.getDate()+2);
					break;
				case 4:
					return new Date(deadline.getDate()+3);
					break;
				case 5:
					return new Date(deadline.getDate()+4);
					break;
				default:
					return new Date();
			}
		}
		public static function didPracticeWord(word:Word, correct:Boolean):void
		{
			var currentPileValue:int = word.leitnerCurrentPile;
			var isRipe:Boolean		 = word.isRipe();
			
			var diff:int
			
			if(correct && isRipe)
			{
				diff=1;
			} else{
				diff=-1;
			}
				
			currentPileValue+=diff;
			
			//secure edgecases
			currentPileValue=(currentPileValue >= NUM_PILES)?NUM_PILES:currentPileValue;
			currentPileValue=(currentPileValue <= 0)?0:currentPileValue;
			
			word.nextDeadline		= getNextDeadline(currentPileValue);
			trace(word.english+" = pile: "+currentPileValue+"= next deadline: "+word.nextDeadline);
			word.leitnerCurrentPile = currentPileValue;
			
			//save word to db
		  	DatabaseHelper.updateWord(word);
		}
		
		public static function sortArray(arr:Array):Array
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
				
		
		}
		
		private static function closeApp(e:Event):void{
		//TODO:
		Application.application.close();
		//force close app
		
		}
		public static function checkRipePeriodAndUpdatePile():void{
			//check last open date
			//if LAST date in the FUTURE - stop process and give a alert
			var today:Date = new Date();
			var lastOpenDate:Date = DatabaseHelper.getLastOpenDate();
			
			
			if(lastOpenDate>today){
			
				//SHOW ALERT
				Alert.show("Tingbudong works with the current date and time, it looks like your system time is set in the past, please check","Alert", 4, Application.application.main  , closeApp);
			
				return;
			}
			DatabaseHelper.refreshLastOpenDate();
			//go through all words and check if a ripe-period has been neglected
			var arr:Array = DatabaseHelper.getInstance().getAllWords();
			for(var i:int=0; i<arr.length;i++){
				var w:Word = arr[i];
				var d:Date = w.getLastDate();
				trace(w.english+", pile: " + w.leitnerCurrentPile);
				if(d >= today){
					//do nothing FINE
				}else{
					//move words that have missed the period back a pile
					didPracticeWord(w, false);
				}	
			}
		}
		
		private static function wordfilterfunction(obj:Word):Boolean {
			// return whether or not the current bandAryCol index meets the filter criteria
			return (obj.leitnerCurrentPile == pileNo);
		}
	
		/* returns a number between 0 and 1*/
		private static function prob():Number {
			return Math.random();
		}
		
		private function randomElement(arr:Array):int {
			return Math.random() % arr.length;
			
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
		}
	
	
	}
}