/**
 * Classe para controle de Som
 * @version 1.0
 * @data 22 de Agosto de 2011
 */
package  {
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Virgilio
	 */
	public class CanalSom {
		//Canal Instanciado
		private var canal:SoundChannel = new SoundChannel();
		//Tipo do Canal: BGM, SFX ou VOZ
		private var tipoCanal:String = "";
		//Nome do audio na biblioteca
		private var nomeAudio:String = "";
		//Objeto de Audio
		private var audio:Sound;
		//Objeto SoundTransform
		private var sTransform:SoundTransform;
		//Volume atual do canal
		private var volumeAtual:Number = 1;
		//Quantidade de vezes da repetição
		private var vezes:Number = 1;
		//Posição do audio
		private var posicao:Number = 0;
		//Estado do canal, Mudo ou Normal
		private var estado:String = "normal";
		
		/**
		 * Método construtor do Canal de Som
		 * @param	_tipo		Tipo do canal, utilizado para classificar os canais: BGM, SFX ou VOZ.
		 * @param	_audio		Nome do audio na Biblioteca, utilizado para iniciar o objeto de som.
		 * @param	_volume		Volume inicial, volume definido entre 0 e 1.
		 * @param	_vezes		Quantidade de Vezes, quantidade de vezes que o som irá repetir 0, 1, ... n. Usar Infinity para loop.
		 */
		public function CanalSom( _tipo:String, _audio:String, _volume:Number = -1, _vezes:Number = 1 ):void {
			
			//Define o audio do canal
			setAudio( _audio );
			//Define o SoundTransform do canal
			setSTransform( _volume );
			
			/**
			 * Atributos de configuração
			 */			
			this.vezes = _vezes;
			this.tipoCanal = _tipo;
			this.nomeAudio = _audio;
			
		}
		
		/**
		 * Atribui o audio para
		 * @param	_audio		Nome do audio na Biblioteca, utilizado para iniciar o objeto de som.
		 */
		private function setAudio ( _audio:String ):void {
			//Instancia o audio da biblioteca
			var classe:Class = getDefinitionByName( _audio ) as Class;
			
			this.audio = new classe(  );
			classe = null;
			
		}
		
		/**
		 * Atribui o SoundTransform ao canal
		 * @param	_volume		Volume inicial, volume definido entre 0 e 1.
		 */
		private function setSTransform ( _volume:Number = -1 ):void {
			//Se o _volume for menor que 0 coloca o volumeAtual como 1
			if ( _volume < 0 ) this.volumeAtual = 1;
			//Caso contrario o volumeAtual é igual ao _volume
			else this.volumeAtual = _volume;
			
			//Atualiza o SoundTransform do canal
			this.sTransform = new SoundTransform( this.volumeAtual );
			
		}
		
		/**
		 * Retorna o SoundTransform atribuido ao canal
		 * @return	SoundTransform
		 */
		public function getSTransform (  ):SoundTransform {
			
			return this.sTransform;
			
		}
		
		/**
		 * Inicia o som
		 * @param	_posicao	Posição onde o som vai se iniciar
		 * @param	_volume		Volume inicial, volume definido entre 0 e 1.
		 * @param	_vezes		Quantidade de Vezes, quantidade de vezes que o som irá repetir 0, 1, ... n. Usar Infinity para loop.
		 */
		public function play ( _posicao:Number = 0, _volume:Number = 0, _vezes:Number = 0 ):void {
			
			if ( _vezes > 0 ) {
				
				this.vezes = _vezes;
				
			}
			
			this.canal = this.audio.play( _posicao, this.vezes, this.sTransform );
			
			if ( this.vezes == Infinity && this.canal.hasEventListener( Event.SOUND_COMPLETE ) == false ) {
				
				this.canal.addEventListener( Event.SOUND_COMPLETE, repeteSom );
				
			}
			
			if ( _volume > 0 ) {
				
				this.setVolume( _volume );
				
			}
			
			if ( this.estado == "mute" ) {
				
				this.setMute( true );
				
			} else {
				
				this.setMute( false );
				
			}
			
		}
		
		/**
		 * Repete o som. utilizada somente dentro da função play
		 * @param	e
		 */
		private function repeteSom( e:Event ):void {
			
			this.canal.removeEventListener( Event.SOUND_COMPLETE, repeteSom );
			play(  );
			
		}
		
		/**
		 * Pausa o som
		 */
		public function pause (  ):void {
			
			this.posicao = this.canal.position;
			stop(  );
			
		}
		
		/**
		 * Resume o som
		 */
		public function resume (  ):void {
			
			play( this.posicao );
			
		}
		
		/**
		 * Para o som
		 */
		public function stop (  ):void {
			
			this.canal.stop(  );
			
		}
		
		/**
		 * 
		 * @param	_volume		Volume inicial, volume definido entre 0 e 1.
		 */
		public function setVolume ( _volume:Number ):void {
			
			var auxSound:SoundTransform = this.canal.soundTransform;
			
			auxSound.volume = _volume;
			this.volumeAtual = _volume;
			
			this.canal.soundTransform = auxSound;
			
		}
		
		/**
		 * Deixa o canal mudo ou normal
		 * @param	_mute		True para ficar mudo, False para tirar o mudo
		 */
		public function setMute ( _mute:Boolean ):void {
			//SoundTransform auxiliar
			var auxSound:SoundTransform = this.canal.soundTransform;
			
			if ( _mute == true ) {
				
				this.estado = "mute";
				
				auxSound.volume = 0;
				
			} else {
				
				this.estado = "normal";
				
				auxSound.volume = this.volumeAtual;
				
			}
			
			this.canal.soundTransform = auxSound;
			
		}
		
		/**
		 * Retorna o tipo do canal: BGM, SFX ou VOZ
		 * @return	tipoCanal
		 */
		public function getTipoCanal (  ):String {
			
			return this.tipoCanal;
			
		}
		
		/**
		 * Retorna o nome do audio na biblioteca
		 * @return	nomeAudio
		 */
		public function getNomeAudio (  ):String {
			
			return this.nomeAudio;
			
		}
		
		/**
		 * Retorna o estado do audio (normal / mute)
		 * @return estado
		 */
		public function getEstado (  ):String {
			
			return this.estado;
			
		}
		
		/**
		 * Retorna o tamanho do som sendo executado no canal
		 * @return	tamanho
		 */
		public function getTempoAudio (  ):Number {
			
			var tamanho:Number = this.audio.length / 1000;
			return tamanho;
			
		}
		
		/**
		 * Destroi o canal
		 */
		public function destroy (  ):void {
			
			this.canal.stop(  );
			this.canal = null
			
			this.audio = null;
			this.sTransform = null;
			
		}
		
	}

}