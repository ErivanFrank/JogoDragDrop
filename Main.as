package  
{
	import fl.transitions.Tween;
	import flash.display.MovieClip;
	import caurina.transitions.Tweener;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.DisplayObject;		
	import flash.sampler.NewObjectSample;	
	import tempo;
	import Som;
	import CanalSom;
	
	/**
	 * ...
	 * @author erivan
	 */
	public class Main extends MovieClip
	{
		var str : String = "objeto1";
		var fase : cenario_mv = new cenario_mv();
		private var startgame : start_mv = new start_mv;
		var fim : EndGame_mv  = new EndGame_mv();	
		var evento : carrinho_mv = new carrinho_mv;
		var passa_fase : positivo_mv = new positivo_mv();
		var ret_fase : negativo_mv = new negativo_mv();
		
		var pos_icinioX : int;
		var pos_inicioY : int;
		var aux_posicao:int = 0;
		var cont = 0;
		var  cronometro : tempo;		
		var flagIniciar : Boolean = false;	
		
		var nomeSolucao : String;
		var aux_alpha:MovieClip;
		var pratileira:MovieClip;
		var hitTest_mc:MovieClip;	
		
		//var som : acertou_sn = new acertou_sn();
		
		
//-----------------------------------------------------------------------------------------------------------------------------------//		
		var flagIniciarfase1 : Boolean = false;
		var fase1 : cenario_mv1;
		var nomeSolucao1 : String;
		var pratileira1:MovieClip;
//-----------------------------------------------------------------------------------------------------------------------------------//		
		var flagIniciarfase2 : Boolean = false;
		var fase2 : cenario_mv2;
		var nomeSolucao2 : String;
		var pratileira2:MovieClip;
//====================================================================================================//

		public function Main() 
		{				
			this.addChild(startgame);
			startgame.mc_box.btn_voltar.alpha = 0.5;
			Tweener.addTween(this,{delay: 3, onComplete:eventosBotao})
		}
		
		
		
		public function eventosBotao():void 
		{
			
			startgame.mc_box.btn_avancar.buttonMode = true;
			
			startgame.mc_box.btn_avancar.addEventListener(MouseEvent.MOUSE_DOWN, evtBotao);			
			startgame.mc_box.btn_avancar.addEventListener(MouseEvent.MOUSE_OUT, evtBotao);
			startgame.mc_box.btn_avancar.addEventListener(MouseEvent.MOUSE_OVER, evtBotao);		
			
		}
		
		
		public function evtBotao(e:MouseEvent):void 
		{
			
			switch(e.type)
			{
				
				case MouseEvent.MOUSE_OUT:
					
					e.currentTarget.gotoAndPlay("out");
					
				break;
				
				case MouseEvent.MOUSE_DOWN:
					
					this.removeEventListener(MouseEvent.MOUSE_DOWN, evtBotao);
					this.removeEventListener(MouseEvent.MOUSE_OUT, evtBotao);
					this.removeEventListener(MouseEvent.MOUSE_OVER, evtBotao);
					
					startgame.mc_box.gotoAndStop("comecar");
					
					
					startgame.mc_box.btn_avancar2.buttonMode = true;
					startgame.mc_box.btn_voltar2.buttonMode = true;
					
					
					
					startgame.mc_box.btn_voltar2.addEventListener(MouseEvent.MOUSE_DOWN, volta);			
					startgame.mc_box.btn_voltar2.addEventListener(MouseEvent.MOUSE_OUT, volta);
					startgame.mc_box.btn_voltar2.addEventListener(MouseEvent.MOUSE_OVER, volta);
			
					startgame.mc_box.btn_avancar2.addEventListener(MouseEvent.MOUSE_DOWN, testaBotao2);			
					startgame.mc_box.btn_avancar2.addEventListener(MouseEvent.MOUSE_OUT, testaBotao2);
					startgame.mc_box.btn_avancar2.addEventListener(MouseEvent.MOUSE_OVER, testaBotao2);
					
				break;
					
				case MouseEvent.MOUSE_OVER:
					
					e.currentTarget.gotoAndPlay("over");
					
				break;
				
			}
			
		}
		
		
		public function volta(e:Event):void 
		{
			switch(e.type)
			{
			case MouseEvent.MOUSE_DOWN:
			startgame.mc_box.gotoAndPlay("comecar");
			startgame.mc_box.addEventListener(MouseEvent.MOUSE_DOWN, evtBotao);
			break;
			}
		}
		
		
		public function testaBotao2(e:Event ):void 
		{
			switch(e.type)
			{
				
				case MouseEvent.MOUSE_OUT:	
					
					e.currentTarget.gotoAndPlay("out");
					
				break;
			
			case MouseEvent.MOUSE_DOWN:		
					
					this.removeChild(startgame);
					this.removeEventListener(MouseEvent.MOUSE_DOWN, testaBotao2);
					this.removeEventListener(MouseEvent.MOUSE_OUT, testaBotao2);
					this.removeEventListener(MouseEvent.MOUSE_OVER, testaBotao2);
					Tweener.addTween(this, { delay: 0.003, onComplete:iniciarJogo1 } );
					
					
				break;
				
				case MouseEvent.MOUSE_OVER:	
				
					e.currentTarget.gotoAndPlay("over");
					
				break;				
				
			}
		}
		
		
//------------------------------------------------------------------------------------------------------------------------------//		
		

		public function iniciarJogo1():void 
		{	
		
		cronometro = new tempo();
		cronometro.iniciar();		
		flagIniciarfase1 = true;		
		cont = 0;
			if (flagIniciarfase1) 
			{	
				fase1 = new cenario_mv1();
				this.addChild(fase1);
				for (var i:int = 0; i < fase1.numChildren ; i++)  
				{
					
					if (fase1.getChildAt(i).name.substr(0,6) == ("objeto"))
					{
						
						hitTest_mc = MovieClip(fase1.getChildAt(i));
						hitTest_mc.addEventListener(MouseEvent.MOUSE_DOWN, Pega1);
						hitTest_mc.addEventListener(MouseEvent.MOUSE_UP, Solta1);					
						hitTest_mc.buttonMode = true;
						hitTest_mc.nomeSolucao1 = "pratileira1" + hitTest_mc.name.substr(6, 2);
						
					}	
					
				}	
				
				hitTest_mc.addEventListener(Event.ENTER_FRAME, evtVerifica);			
				
			}
			trace(hitTest_mc)
			
		}	
		
		
		public function Pega1(e:MouseEvent):void 
		{
			
				hitTest_mc = e.currentTarget as MovieClip;				
				hitTest_mc.startDrag();
				trace("OBJ: ", hitTest_mc.name, hitTest_mc.name.substr(6, 2));
				trace("PRAT: ", fase1["pratileira1"+ hitTest_mc.name.substr(6, 2)].name);				
				//this["pratileira"+ hitTest_mc.name.substr(6, 2)].parent.setChildIndex(e.currentTarget, MovieClip(e.currentTarget.parent).numChildren-1);
				e.currentTarget.parent.setChildIndex(e.currentTarget, MovieClip(e.currentTarget.parent).numChildren-1);
				pos_icinioX = hitTest_mc.x;
				pos_inicioY = hitTest_mc.y;
				
				
				trace("\b\b\b\b\b\b\b",hitTest_mc.name);

			
		}
		
		
		
		public function Solta1(e:MouseEvent):void 
		{
			
			e.currentTarget.stopDrag();				
			pratileira1 = e.currentTarget.parent[e.currentTarget.nomeSolucao1];			
			trace(pratileira1.name);
			
			if (this.hitTest_mc.hitTestObject(pratileira1)) 
			{
				
				
					aux_alpha:MovieClip;
					for (var k:int = 1; k <= 4 ; k++)
					{
					
						if (hitTest_mc.name.substr(6, 4) == "lt0" + k)
						{				
						
						aux_alpha = pratileira1["lt0" + k] as MovieClip;							
						aux_alpha.alpha = 1;
						//Som.iniciarSom("sfx4", Som.TIPO_SFX, "acertou_sn",0.4, 1);
						
							
						}
						
						if (hitTest_mc.name.substr(6, 4) == "dc0" + k)
						{					 
					
							this.hitTest_mc.x = pos_icinioX;
							this.hitTest_mc.y = pos_inicioY;
							
							
						}
						
						if (hitTest_mc.name.substr(6, 4) == "vg0" + k)
						{				
							
							this.hitTest_mc.x = pos_icinioX;
							this.hitTest_mc.y = pos_inicioY;
							
						}
						
						if (hitTest_mc.name.substr(6, 4) == "cn0" + k)
						{					 
					
							this.hitTest_mc.x = pos_icinioX;
							this.hitTest_mc.y = pos_inicioY;
							
							
						}
						
						if (hitTest_mc.name.substr(6, 4) == "cr0" + k)
						{	
							
							aux_alpha = pratileira1["cr0" + k] as MovieClip;							
							aux_alpha.alpha = 1;
							//Som.iniciarSom("sfx4", Som.TIPO_SFX, "acertou_sn",0.4, 1);
							
						}
						
						
						
					}
					
					
					for (var l:int = 0; l <= 5 ; l++) 
					{
						if (hitTest_mc.name.substr(6, 4) == "fr0" + l)
						{	
							
							this.hitTest_mc.x = pos_icinioX;
							this.hitTest_mc.y = pos_inicioY;
							
							
						}
						
					}	
					
					hitTest_mc.visible = false;
					hitTest_mc.stopDrag();				
					this.hitTest_mc.buttonMode = false;				
					this.removeEventListener(MouseEvent.MOUSE_DOWN, Pega1);
					this.removeEventListener(MouseEvent.MOUSE_OUT, Solta1);	
					cont++;
					trace(cont);
					Som.iniciarSom("sfx4", Som.TIPO_SFX, "acertou_sn",0.4, 1);
					
						
			} 				
			else
			{	
				
				this.removeEventListener(MouseEvent.MOUSE_DOWN, Pega1);
				this.removeEventListener(MouseEvent.MOUSE_OUT, Solta1);
				this.hitTest_mc.x = pos_icinioX;
				this.hitTest_mc.y = pos_inicioY;
				Som.iniciarSom("sfx4", Som.TIPO_SFX, "errou_sn",0.4, 1);
				
			}	
			
			
			if (cont == 7)
			{	
				cont = 0;
				flagIniciarfase1 = false;
				this.addChild(passa_fase);							
				passa_fase.gotoAndPlay("mc_positivo");
				Tweener.addTween(this,{delay: 3, onComplete:iniciarJogo2})			
				
			}
			
			
			
		}
		
		
//==================================================================================================//
		public function iniciarJogo2():void 
		{	
		
		cronometro = new tempo();
		cronometro.iniciar();
		cont = 0;
		flagIniciarfase2 = true;		
		
			if (flagIniciarfase2) 
			{	
				fase2 = new cenario_mv2();
				this.addChild(fase2);
				for (var i:int = 0; i < fase2.numChildren ; i++)  
				{
					trace(fase2.numChildren)
					if (fase2.getChildAt(i).name.substr(0,6) == ("objeto"))
					{
						
						hitTest_mc = MovieClip(fase2.getChildAt(i));
						hitTest_mc.addEventListener(MouseEvent.MOUSE_DOWN, Pega2);
						hitTest_mc.addEventListener(MouseEvent.MOUSE_UP, Solta2);					
						hitTest_mc.buttonMode = true;
						hitTest_mc.nomeSolucao2 = "pratileira2" + hitTest_mc.name.substr(6, 2);
						
					}	
					
				}	
				
				hitTest_mc.addEventListener(Event.ENTER_FRAME, evtVerifica);			
				
			}
			trace(hitTest_mc)
			
		}	
		
		
		public function Pega2(e:MouseEvent):void 
		{
			
				hitTest_mc = e.currentTarget as MovieClip;				
				hitTest_mc.startDrag();
				trace("OBJ: ", hitTest_mc.name, hitTest_mc.name.substr(6, 2));
				trace("PRAT: ", fase2["pratileira2"+ hitTest_mc.name.substr(6, 2)].name);				
				//this["pratileira"+ hitTest_mc.name.substr(6, 2)].parent.setChildIndex(e.currentTarget, MovieClip(e.currentTarget.parent).numChildren-1);
				e.currentTarget.parent.setChildIndex(e.currentTarget, MovieClip(e.currentTarget.parent).numChildren-1);
				pos_icinioX = hitTest_mc.x;
				pos_inicioY = hitTest_mc.y;
				
				
				trace("\b\b\b\b\b\b\b",hitTest_mc.name);

			
		}
		
		
		
		public function Solta2(e:MouseEvent):void 
		{
			
			e.currentTarget.stopDrag();				
			pratileira2 = e.currentTarget.parent[e.currentTarget.nomeSolucao2];			
			trace(pratileira2.name);
			
			if (this.hitTest_mc.hitTestObject(pratileira2)) 
			{
				
				
					aux_alpha:MovieClip;
					for (var m:int = 1; m <= 4 ; m++)
					{
					//trace("OBJ: ",hitTest_mc.name.substr(6, 4));
						if (hitTest_mc.name.substr(6, 4) == "lt0" + m)
						{				
						
						aux_alpha = pratileira2["lt0" + m] as MovieClip;							
						aux_alpha.alpha = 1;
						
							
						}
						
						if (hitTest_mc.name.substr(6, 4) == "dc0" + m)
						{					 
					
							this.hitTest_mc.x = pos_icinioX;
							this.hitTest_mc.y = pos_inicioY;
							
							
						}
						
						if (hitTest_mc.name.substr(6, 4) == "vg0" + m)
						{				
							
							aux_alpha = pratileira2["vg0" + m] as MovieClip;							
							aux_alpha.alpha = 1;
							
							
						}
						
						if (hitTest_mc.name.substr(6, 4) == "cn0" + m)
						{					 
					
						aux_alpha = pratileira2["cn0" + m] as MovieClip;							
						aux_alpha.alpha = 1;
						
							
						}
						
						if (hitTest_mc.name.substr(6, 4) == "cr0" + m)
						{	
							
							aux_alpha = pratileira2["cr0" + m] as MovieClip;							
							aux_alpha.alpha = 1;
							
							
						}
						
						
						
					}
					
					
					for (var n:int = 0; n <= 5 ; n++) 
					{
						if (hitTest_mc.name.substr(6, 4) == "fr0" + n)
						{	
							
							this.hitTest_mc.x = pos_icinioX;
							this.hitTest_mc.y = pos_inicioY;
							
							
						}
						
					}	
					
					hitTest_mc.visible = false;
					hitTest_mc.stopDrag();				
					this.hitTest_mc.buttonMode = false;				
					this.removeEventListener(MouseEvent.MOUSE_DOWN, Pega2);
					this.removeEventListener(MouseEvent.MOUSE_OUT, Solta2);	
					cont++;
					trace(cont);
					Som.iniciarSom("sfx4", Som.TIPO_SFX, "acertou_sn",0.4, 1);
					
					
			} 				
			else
			{	
				
				this.removeEventListener(MouseEvent.MOUSE_DOWN, Pega2);
				this.removeEventListener(MouseEvent.MOUSE_OUT, Solta2);
				this.hitTest_mc.x = pos_icinioX;
				this.hitTest_mc.y = pos_inicioY;
				Som.iniciarSom("sfx4", Som.TIPO_SFX, "errou_sn",0.4, 1);
				
			}	
			
			if (cont == 15)
			{	
				flagIniciarfase2 = false;
				this.addChild(passa_fase);							
				passa_fase.gotoAndPlay("mc_positivo");
				Tweener.addTween(this,{delay: 3, onComplete:iniciarJogo})			
				
			}
			
			
			
		}
	
		
		
//==================================================================================================//		
		
//------------------------------------------------------------------------------------------------------------------------------//		
		public function iniciarJogo():void 
		{	
		
		cronometro = new tempo();
		cronometro.iniciar();
		cont = 0;
		flagIniciar = true;		
		
			if (flagIniciar) 
			{							
				this.addChild(fase);
				for (var i:int = 0; i < fase.numChildren ; i++)  
				{
					if (fase.getChildAt(i).name.substr(0,6) == ("objeto"))
					{
						
						hitTest_mc = MovieClip(fase.getChildAt(i));
						hitTest_mc.addEventListener(MouseEvent.MOUSE_DOWN, Pega);
						hitTest_mc.addEventListener(MouseEvent.MOUSE_UP, Solta);					
						hitTest_mc.buttonMode = true;
						hitTest_mc.nomeSolucao = "pratileira" + hitTest_mc.name.substr(6, 2);
						
					}	
					
				}	
				
				hitTest_mc.addEventListener(Event.ENTER_FRAME, evtVerifica);			
				
			}	
			
		}	
		
		
		public function Pega(e:MouseEvent):void 
		{
			
				hitTest_mc = e.currentTarget as MovieClip;				
				hitTest_mc.startDrag();
				trace("OBJ: ", hitTest_mc.name, hitTest_mc.name.substr(6, 2));
				trace("PRAT: ", fase["pratileira"+ hitTest_mc.name.substr(6, 2)].name);				
				//this["pratileira"+ hitTest_mc.name.substr(6, 2)].parent.setChildIndex(e.currentTarget, MovieClip(e.currentTarget.parent).numChildren-1);
				e.currentTarget.parent.setChildIndex(e.currentTarget, MovieClip(e.currentTarget.parent).numChildren-1);
				pos_icinioX = hitTest_mc.x;
				pos_inicioY = hitTest_mc.y;	
			
		}
		
		
		
		public function Solta(e:MouseEvent):void 
		{
			
			e.currentTarget.stopDrag();				
			pratileira = e.currentTarget.parent[e.currentTarget.nomeSolucao];			
			trace(pratileira.name);
			
			if (this.hitTest_mc.hitTestObject(pratileira)) 
			{
				
				
					aux_alpha:MovieClip;
					for (var h:int = 1; h <= 4 ; h++)
					{
					//trace("OBJ: ",hitTest_mc.name.substr(6, 4));
						if (hitTest_mc.name.substr(6, 4) == "lt0" + h)
						{				
						
						aux_alpha = pratileira["lt0" + h] as MovieClip;							
						aux_alpha.alpha = 1;
					
							
						}
						
						if (hitTest_mc.name.substr(6, 4) == "cr0" + h)
						{					 
					
						trace("\b\bEntrou");
						aux_alpha = pratileira["cr0" + h] as MovieClip;							
						aux_alpha.alpha = 1;
						
							
							
						}
						
						if (hitTest_mc.name.substr(6, 4) == "cn0" + h)
						{					 
					
						trace("\b\bEntrou");
						aux_alpha = pratileira["cn0" + h] as MovieClip;							
						aux_alpha.alpha = 1;
						
												
							
						}
						
						if (hitTest_mc.name.substr(6, 4) == "dc0" + h)
						{					 
					
						trace("\b\bEntrou");
						aux_alpha = pratileira["dc0" + h] as MovieClip;						
						aux_alpha.alpha = 1;
						
							
						}
						
						
						if (hitTest_mc.name.substr(6, 4) == "vg0" + h)
						{					 
					
						trace("\b\bEntrou");
						aux_alpha = pratileira["vg0" + h] as MovieClip;						
						aux_alpha.alpha = 1;
					
							
						}						
						
						
						
					}
					
					
					for (var j:int = 0; j <= 5 ; j++) 
					{
						if (hitTest_mc.name.substr(6, 4) == "fr0" + j)
						{					 
					
						trace("\b\bEntrou");
						aux_alpha = pratileira["fr0" + j] as MovieClip;						
						aux_alpha.alpha = 1;
						Som.iniciarSom("sfx4", Som.TIPO_SFX, "acertou_sn",0.4, 1);
							
						}
						
					}	
					
					hitTest_mc.visible = false;
					hitTest_mc.stopDrag();				
					this.hitTest_mc.buttonMode = false;				
					this.removeEventListener(MouseEvent.MOUSE_DOWN, Pega);
					this.removeEventListener(MouseEvent.MOUSE_OUT, Solta);	
					cont++;
					Som.iniciarSom("sfx4", Som.TIPO_SFX, "acertou_sn",0.4, 1);
					
					
						
			} 				
			else
			{	
				
				this.removeEventListener(MouseEvent.MOUSE_DOWN, Pega);
				this.removeEventListener(MouseEvent.MOUSE_OUT, Solta);
				this.hitTest_mc.x = pos_icinioX;
				this.hitTest_mc.y = pos_inicioY;
				Som.iniciarSom("sfx4", Som.TIPO_SFX, "errou_sn",0.4, 1);
				
				
			}	
					
					if (cont == 23)
					{					
						trace("Entrou");
						this.addChild(fim);							
						fim.gotoAndPlay("POSITIVO");			
						
						
					}
			
			
			
		}
		
		
		public function telaGameOuver():void 
		{
			
			this.addChild(fim);
			fim.gotoAndPlay("NEGATIVO");
			
		}
		
		public function removeJogo():void 
		{
			trace("entrou");
			cont = 0;
			this.removeChild(ret_fase);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, Pega1);
			this.removeEventListener(MouseEvent.MOUSE_OUT, Solta1);				
			flagIniciarfase1 = true;			
			iniciarJogo1();
		}
		
		
		public function removeJogo2():void 
		{
			
			trace("entrou");
			cont = 0;			
			removeChild(ret_fase);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, Pega2);
			this.removeEventListener(MouseEvent.MOUSE_OUT, Solta2);				
			flagIniciarfase2 = true;		
			iniciarJogo2();
		}
		
		
		
		public function evtVerifica(e:Event):void 
		{
			if (hitTest_mc.x < 2 || hitTest_mc.x > 870 || hitTest_mc.y < 2 || hitTest_mc.y > 495)
			{
				
				hitTest_mc.stopDrag();
				hitTest_mc.x = pos_icinioX;
				hitTest_mc.y = pos_inicioY;			
				hitTest_mc.removeEventListener(Event.ENTER_FRAME, evtVerifica);
				trace(pos_icinioX);
				trace(pos_inicioY);
				
			}
			
			
						
			fase.tempo_txt.text = cronometro.texttempo;	
			if (flagIniciarfase1 == true) 
			{
				fase1.tempo_txt.text = cronometro.texttempo;
				if (fase1.tempo_txt.text == "00:60")
				{	
				
					
					flagIniciarfase1 = false;			
					this.addChild(ret_fase);							
					ret_fase.gotoAndPlay("mc_negativo");
					fase1.removeEventListener(Event.ENTER_FRAME, evtVerifica);
					Tweener.addTween(this, { delay: 3, onComplete:removeJogo} )		
					
					
					
				}
				
			}

			
			if (flagIniciarfase2 == true)
			{
				
				fase2.tempo_txt.text = cronometro.texttempo;
					if (fase2.tempo_txt.text == "00:40")			
					{	
					
						
						flagIniciarfase2 = false;			
						this.addChild(ret_fase);							
						ret_fase.gotoAndPlay("mc_negativo");
						fase2.removeEventListener(Event.ENTER_FRAME, evtVerifica);
						Tweener.addTween(this, { delay: 3, onComplete:removeJogo2} )	
						
						
					}
			}

			
			
			
			if (fase.tempo_txt.text == "00:60")
			{	
				
				telaGameOuver();
				fase.removeEventListener(Event.ENTER_FRAME, evtVerifica);			
				
			}		
			
		}
		
		
	}

}