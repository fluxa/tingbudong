package events
{
	import flash.events.Event;
	
	import model.Grammar;
	import model.Vocab;
	import model.Word;

	public class VocabEvent extends Event
	{
		public static const ADD_VOCAB:String = "aVOCAB";
		public static const NEW_VOCAB:String = "newVOCAB";
		public static const UPDATE_VOCAB:String = "uVOCAB";
		public static const DELETE_VOCAB:String = "dVOCAB";
		
		public static const ADD_GRAMMAR:String = "aGRAMMAR";
		public static const UPDATE_GRAMMAR:String = "uGRAMMAR";
		public static const DELETE_GRAMMAR:String = "dGRAMMAR";
		
		public var vocab:Word;
		public var gramm:Grammar;
		public function VocabEvent(type:String, wrd:Vocab)
		{
			super(type, true, false);
			
			if(type == ADD_VOCAB || type == NEW_VOCAB || type == UPDATE_VOCAB || type == DELETE_VOCAB)
			this.vocab	= wrd as Word;
			else if(type == ADD_GRAMMAR || type == UPDATE_GRAMMAR || type == DELETE_GRAMMAR)
			this.gramm = wrd as Grammar;
		}
		
	}
}