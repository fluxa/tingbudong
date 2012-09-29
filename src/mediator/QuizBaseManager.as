package mediator
{
	import events.EventManager;
	import events.SelectArrayEvent;
	
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.DisplayObject;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import helpers.AIRUtils;
	import helpers.DatabaseHelper;
	import helpers.XMLParsingHelper;
	
	import model.QuizSettings;
	import model.QuizVocabulary;
	import model.Session;
	import model.Vocab;
	import model.Word;
	
	import mx.controls.Alert;
	import mx.controls.RadioButton;
	import mx.core.Window;
	import mx.managers.PopUpManager;
	
	import views.SelectSessionsView;
	import views.SettingsView2;
	import views.quizes.QuizView;
	import views.quizes.QuizView1;
	import views.quizes.QuizView3;
	import views.quizes.QuizView4;
	import views.quizes.Quizview2;
	
	public class QuizBaseManager extends BaseMediator
	{
		/***********************************************/
		/*VARIABLES*/
		/***********************************************/

		private var baseView:SettingsView2;
		public var quizVocab:QuizVocabulary;

		/***********************************************/
		/*CONSTRUCTOR*/
		/***********************************************/
		public function QuizBaseManager()
		{
			super();
		}
		
		/*register the mediator and event listeners*/
		override public function register():void{
			quizVocab 	= QuizVocabulary.getInstance();
			
			EventManager.getInstance().addEventListener(EventManager.OpenQuizBaseEvent , populateView);
			EventManager.getInstance().addEventListener(EventManager.StartQuizEvent1 , startingQuiz1);
			EventManager.getInstance().addEventListener(EventManager.StartQuizEvent2 , startingQuiz1);
			EventManager.getInstance().addEventListener(EventManager.StartQuizEvent3 , startingQuiz1);
			EventManager.getInstance().addEventListener(EventManager.StartQuizEvent4 , startingQuiz1);
			EventManager.getInstance().addEventListener(EventManager.StartQuizEvent5 , startingQuiz1);
			
			baseView.quiz1.btn.addEventListener(MouseEvent.CLICK, function():void{EventManager.getInstance().dispatchEvent(new Event(EventManager.StartQuizEvent1));} );
			baseView.quiz2.btn.addEventListener(MouseEvent.CLICK, function():void{EventManager.getInstance().dispatchEvent(new Event(EventManager.StartQuizEvent2));} );
			baseView.quiz3.btn.addEventListener(MouseEvent.CLICK, function():void{EventManager.getInstance().dispatchEvent(new Event(EventManager.StartQuizEvent3));} );
			baseView.quiz4.btn.addEventListener(MouseEvent.CLICK, function():void{EventManager.getInstance().dispatchEvent(new Event(EventManager.StartQuizEvent4));} );
			baseView.quiz5.btn.addEventListener(MouseEvent.CLICK, function():void{EventManager.getInstance().dispatchEvent(new Event(EventManager.StartQuizEvent5));} );
			
			baseView.closebtn.addEventListener(MouseEvent.CLICK, function():void{EventManager.getInstance().dispatchEvent(new Event(EventManager.CloseQuizBaseEvent));});
			populateView();
			
			prepareBacksideSettings();
			baseView.quiz1.mainSelectionRadioGroup.selectedValue	= this.quizVocab.settings.quiz1_type;
			baseView.quiz3.mainSelectionRadioGroup.selectedValue	= this.quizVocab.settings.quiz2_type;
			baseView.quiz1.done_btn.addEventListener(MouseEvent.CLICK, settingsChange);
			baseView.quiz3.done_btn.addEventListener(MouseEvent.CLICK, settingsChange);
			
			
		}
		/***********************************************/
		/*PUBLIC FUNCTIONS*/
		/***********************************************/
		//populates settings view with settings + number of words
		public function populateView(e:Event= null):void
		{
			baseView.visible = true;
			//baseView.vocabview.words = quizVocab.quizWords;
			setQuizStatus();
			
		}
		/***********************************************/
		/*PRIVATE FUNCTIONS*/
		/***********************************************/
		private function prepareBacksideSettings():void{
		
			var rb0:RadioButton = new RadioButton();
			rb0.group = baseView.quiz1.mainSelectionRadioGroup;
			rb0.label = "Show All";
			rb0.value = QuizSettings.SHOW_ALL;
			baseView.quiz1.backside.addChild(rb0);
			rb0.x = 10;
			rb0.y = 10;
			
			var rb1:RadioButton = new RadioButton();
			rb1.group = baseView.quiz1.mainSelectionRadioGroup;
			rb1.label = "chinese / english";
			rb1.value = QuizSettings.CHINESE_ENGLISH;
			baseView.quiz1.backside.addChild(rb1);
			rb1.x = 10;
			rb1.y = 30;
			
			var rb2:RadioButton = new RadioButton();
			rb2.group = baseView.quiz1.mainSelectionRadioGroup;
			rb2.label = "english / chinese";
			rb2.value = QuizSettings.ENGLISH_CHINESE;
			baseView.quiz1.backside.addChild(rb2);
			rb2.x = 10;
			rb2.y = 50;
			
			var rb3:RadioButton = new RadioButton();
			rb3.group = baseView.quiz1.mainSelectionRadioGroup;
			rb3.label = "pinyin / character";
			rb3.value = QuizSettings.PINYIN_CHARACTER;
			baseView.quiz1.backside.addChild(rb3);
			rb3.x = 10;
			rb3.y = 70;
			
			var rb11:RadioButton = new RadioButton();
			rb11.group = baseView.quiz3.mainSelectionRadioGroup;
			rb11.label = "chinese / english";
			rb11.value = QuizSettings.CHINESE_ENGLISH;
			rb11.x = 10;
			rb11.y = 10;
			baseView.quiz3.backside.addChild(rb11);
			
			var rb22:RadioButton = new RadioButton();
			rb22.group = baseView.quiz3.mainSelectionRadioGroup;
			rb22.label = "english / chinese";
			rb22.value = QuizSettings.ENGLISH_CHINESE;
			rb22.x = 10;
			rb22.y = 30;
			baseView.quiz3.backside.addChild(rb22);
			
			var rb33:RadioButton = new RadioButton();
			rb33.group = baseView.quiz3.mainSelectionRadioGroup;
			rb33.label = "pinyin / character";
			rb33.value = QuizSettings.PINYIN_CHARACTER;
			rb33.x = 10;
			rb33.y = 50;
			baseView.quiz3.backside.addChild(rb33);
		}
		
		
		private function setQuizStatus():void{

			//update graphs
			baseView.vocabview.dataXML 		= XMLParsingHelper.getVocabXML(Vocab.CURRENT_KNOWLEDGE, quizVocab.quizWords);		
			baseView.vocabview.start();
			
			//reset quizbuttons:
			baseView.quiz1.btn.enabled = true;	
			baseView.quiz2.btn.enabled = true;	
			baseView.quiz3.btn.enabled = true;	
			baseView.quiz4.btn.enabled = true;			
			baseView.quiz5.btn.enabled = true;	
			//update quizboxes
			var qArr:Array = new Array(0,0,0,0,0);
			
			for(var i:int=1;i<6;i++){
			
				for(var e:int=0;e<quizWordslen;e++){
					if(quizVocab.quizWords[e] is Vocab){
						var wrd:Vocab = quizVocab.quizWords[e];
						qArr[i-1] += wrd.quizObj["quiz"+i+"Status"];	
					}
				}
				if(i==4){
					var quizWordsHanzilen:int 	= quizVocab.getQuizWordsForHanzi().length;
					baseView.quiz4.percentage.text = (qArr[i-1] == 0 && quizWordsHanzilen == 0)? "0%" :Math.round((qArr[i-1]/quizWordsHanzilen)*100) +"%";
					baseView.quiz4.wordscount.text = qArr[i-1].toString()+" of "+quizWordsHanzilen.toString();	
					baseView.quiz4.btn.enabled 	= false;
					//if(quizWordsHanzilen == 0) baseView.quiz4.btn.enabled 	= false;
				}else if(i==2){
					var quizWordsPicturelen:int = quizVocab.getQuizWordsWithPictures().length;
					baseView.quiz2.percentage.text = (qArr[i-1] == 0 && quizWordsPicturelen == 0)? "0%" :Math.round((qArr[i-1]/quizWordsPicturelen)*100) +"%";
					baseView.quiz2.wordscount.text = qArr[i-1].toString()+" of "+quizWordsPicturelen.toString();
					if(quizWordsPicturelen < 2) baseView.quiz2.btn.enabled = false;
				}else if(i==5){
					var quizSentenceslen:int 	= quizVocab.getQuizSentences().length;
					baseView.quiz5.percentage.text = (qArr[i-1] == 0 && quizSentenceslen == 0)? "0%" :Math.round((qArr[i-1]/quizSentenceslen)*100) +"%";
					baseView.quiz5.wordscount.text = "0 of "+quizSentenceslen.toString();	
					if(quizSentenceslen == 0) baseView.quiz5.btn.enabled 	= false;
				}else{
					var quizWordslen:int 		= quizVocab.getQuizWordsNoGrammar().length;
					baseView["quiz"+i].percentage.text = (qArr[i-1] == 0 && quizWordslen == 0)? "0%" : Math.round((qArr[i-1]/quizWordslen)*100) +"%";
					baseView["quiz"+i].wordscount.text = qArr[i-1].toString()+" of "+quizWordslen.toString();
					if(quizWordslen == 0) {
						baseView.quiz1.btn.enabled 	= false;
						baseView.quiz3.btn.enabled 	= false;
					}
				}
			}
			
			//disable character, picture, grammar test if no words are availble
			
			
		
			
		}
		private function settingsChange(e:MouseEvent):void{
		
			if(e.currentTarget == baseView.quiz1.done_btn)
			this.quizVocab.settings.quiz1_type 		= baseView.quiz1.mainSelectionRadioGroup.selectedValue.valueOf();
			else
			this.quizVocab.settings.quiz2_type		= baseView.quiz3.mainSelectionRadioGroup.selectedValue.valueOf();
		}
		private function closeBaseView(e:Event):void{
		
		baseView.visible = false;
		}
		public function startingQuiz1(e:Event):void
		{
			var window:NativeWindow = view.root.stage.nativeWindow;
			
			window.visible = false;
			
			if(NativeApplication.supportsSystemTrayIcon)
			{
				SystemTrayIcon(NativeApplication.nativeApplication.icon).bitmaps = [baseView.icon32];
				SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip = "Taking Quiz..";
				
			} 
			else if(NativeApplication.supportsDockIcon)
			{
				DockIcon(NativeApplication.nativeApplication.icon).bitmaps = [baseView.icon128];
				DockIcon(NativeApplication.nativeApplication.icon).bounce("Taking Quiz...");
				
			}
			
			var swidth:int = flash.display.Screen.mainScreen.bounds.width;
			var sheight:int = flash.display.Screen.mainScreen.bounds.height;
			
			var wwidth:int = 480;
			var wheight:int = 320;
			
			var quizWindow:Window = new Window();
			quizWindow.width = wwidth;
			quizWindow.height = wheight;
			quizWindow.title = "QUIZ";
			quizWindow.horizontalScrollPolicy = "false";
			quizWindow.verticalScrollPolicy = "false";
			quizWindow.resizable = false;
			quizWindow.showStatusBar = false;
			
			//Add view to window
			if(e.type == EventManager.StartQuizEvent1){
				
				quizWindow.width = wwidth;
				quizWindow.height = wheight;
				quizWindow.addChild(openQuiz(window, quizWindow, new QuizView()));
			
			}else if(e.type == EventManager.StartQuizEvent2){
				
				quizWindow.width = 480;
				quizWindow.height = 485;
				quizWindow.addChild(openQuiz(window, quizWindow,  new QuizView1()));
				
			}else if(e.type == EventManager.StartQuizEvent3){
				quizWindow.width = 480;
				quizWindow.height = 600;
				quizWindow.addChild(openQuiz(window, quizWindow,  new Quizview2()));
				
			}else if(e.type == EventManager.StartQuizEvent4){
				quizWindow.width = 480;
				quizWindow.height = 715;
				quizWindow.addChild(openQuiz(window, quizWindow,  new QuizView3()));
			}else if(e.type == EventManager.StartQuizEvent5){
				quizWindow.width = 670;
				quizWindow.height = 300;
				quizWindow.addChild(openQuiz(window, quizWindow,  new QuizView4()));
			}
			
			quizWindow.open(true);
		}
		private function openQuiz(window:NativeWindow, quizWindow:Window, quizView:Object):DisplayObject{

			quizView.mainWindow = window;
			quizView.thisWindow = quizWindow;
			quizView.quizVocabulary = quizVocab;
			quizView.addEventListener(Event.CLOSE, handleQuizClose, false, 0, true);
			
			return quizView as DisplayObject;
			
		}
		protected function handleQuizClose(e:Event):void
		{
			var quizView:Object = e.currentTarget;
			quizView.thisWindow.close();
			quizView.mainWindow.visible = true;
			
			quizView = null;
			NativeApplication.nativeApplication.icon.bitmaps = [];
			setQuizStatus();
			//temporarily taken out
			//EventManager.getInstance().dispatchEvent(new Event(EventManager.StopQuizEvent));
		}
		
		public function set view(value:SettingsView2):void
		{
			baseView = value;
		}
		
		public function get view():SettingsView2
		{
			return baseView;
		}
		
	}
}