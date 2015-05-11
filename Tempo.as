package 
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Savian
	 */
	public class tempo extends MovieClip 
	{
		public var conta_tempo :Timer;
		public var segundos     :Number = 0;
		//var textButton:TextField = new TextField(); //variavel de craiçao de txt dinamico
		//var format:TextFormat = new TextFormat(); //variavel de formatação
		
		public var texttempo:String = new String();
		
		public function tempo()
		{	
			conta_tempo = new Timer( 1000);
			
			conta_tempo.addEventListener(TimerEvent.TIMER, atualizaTempo );
				
		}
		
		public function atualizaTempo(temp:TimerEvent):void
		{
			segundos++;
			var min:Number = Math.floor(segundos / 60);
			
			var seg:Number = Math.round(segundos % 60);
			
			var minStr:String = ((min < 10) ? "0" :"") + min.toString();
			
			var secStr:String = ((seg < 10) ? "0" :"") + seg.toString();
			
			texttempo = minStr + ":" + secStr;
		}
		
		public function iniciar() {
			
			conta_tempo.start();
			
		}
		
		public function pausar() {
		
			conta_tempo.stop();
		}
		
	}
	
}