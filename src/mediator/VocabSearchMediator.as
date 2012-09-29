package mediator
{
	import events.VocabEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import helpers.CDictHelper;
	import helpers.DatabaseHelper;
	
	import model.Word;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import views.Main;
	import views.VocabSearch;
	import views.searchresults.AddVocabWindow;
	
	public class VocabSearchMediator extends BaseMediator
	{
		private var _mainView:Main;
		private var _view:VocabSearch;
		
		public function VocabSearchMediator()
		{
			super();
		}
		
		override public function register():void{
			
			//vocab search event listeners
			view.searchButton.addEventListener(MouseEvent.CLICK, onSearchButtonClick );
			view.searchInput.addEventListener(KeyboardEvent.KEY_UP, keyUpListener);
			view.searchDictionary.addEventListener(MouseEvent.CLICK, onSearchButtonClick);
			view.searchMyWords.addEventListener(MouseEvent.CLICK, onSearchButtonClick);
			view.resultscontainer.addEventListener(VocabEvent.ADD_VOCAB, openPopup);
			view.resultscontainer.addEventListener(VocabEvent.DELETE_VOCAB, deleteVocab);
			view.resultscontainer.addEventListener(VocabEvent.UPDATE_VOCAB, openPopup);
			view.addButton.addEventListener(MouseEvent.CLICK, openVocabAdd );
		}
		private function keyUpListener(e:KeyboardEvent):void{
		
			if(e.keyCode == Keyboard.ENTER){
				onSearchButtonClick();
			
			}
		}
		public function set view( value:VocabSearch ):void
		{
			_view = value;
		}
		
		public function get view( ):VocabSearch
		{
			return _view;
		}
		private function deleteVocab(e:VocabEvent):void{
		
			
			DatabaseHelper.deleteWord(e.vocab.id);
			onSearchButtonClick();
		
		}
		private function openPopup(e:VocabEvent = null):void{
		
				
			
				var sWin:AddVocabWindow = new AddVocabWindow();
				sWin.container = _view;
				if(e== null){
					sWin.activeWord = new Word();
					sWin.update = false;
				}else{
				sWin.activeWord = e.vocab;
				sWin.update = (e.type == VocabEvent.UPDATE_VOCAB);
				}

				PopUpManager.addPopUp( sWin, Application.application as DisplayObject, true );
				PopUpManager.centerPopUp( sWin );
		
		}
		protected function onSearchButtonClick(event:Event=null):void
		{
			
			var response:Array;
			var testresponse:Array ;
			var res:Array; 
			if(view.searchInput.text == "" || view.searchInput.text == " ") return;
			
			if(view.searchDictionary.selected && view.searchMyWords.selected)
			{
				response 		= DatabaseHelper.getInstance().getWordsWithSearchString(view.searchInput.text, 100);
				testresponse 	= CDictHelper.getInstance().search(view.searchInput.text, 100);
			}
			else if(view.searchDictionary.selected)
			{
				response		= new Array();
				testresponse 	= CDictHelper.getInstance().search(view.searchInput.text, 100);
			}
			else if(view.searchMyWords.selected)
			{
				response 		= DatabaseHelper.getInstance().getWordsWithSearchString(view.searchInput.text, 100);
				testresponse 	= new Array();
			}
			else
			{
				response 		= new Array();
				testresponse 	= new Array();
				
			}
			
			res = new Array(response, testresponse);
			view.resultsNr.text = response.length+" words found in your words, "+testresponse.length+" found in the dictionairy.";
			/*if(response.length == 0 && testresponse.length == 0){
			
				Alert.show("No results found, cancel to check spelling and try again or OK to add this word!","Alert",(Alert.CANCEL | Alert.OK),_view,dosomething);
				
			}*/
			_view.resultscontainer.dataProvider = res;
		}
		private function openVocabAdd(event:MouseEvent):void{
		
			openPopup();
		}
	}
}