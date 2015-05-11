/**
 * Classe para controle de Som
 * @version 1.0
 * @data 22 de Agosto de 2011
 */
package {
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.events.Event;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.getDefinitionByName; //utilizada para instanciar objeto dinamicamente
	
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	
	/**
	 * Classe para controle de som dos OAs
	 * @author Virgilio
	 */
	public class Som {
		
		//Objeto que irá conter os canais de audio e suas configurações
		private static var canais:Object = new Object();
		
		//String de mensagem de erro
		private static var msgErro:String = "";
		
		//TimeOut Conf
		private static var timeOutConf:Object = new Object();
		
		/**
		 * Tipos de Canais
		 */
		public static const TIPO_BGM:String = "BGM";
		public static const TIPO_SFX:String = "SFX";
		public static const TIPO_VOZ:String = "VOZ";
		
		/**
		 * Modos dos Canais (mute / normal)
		 */
		private static var modoBGM:String = "normal";
		private static var modoSFX:String = "normal";
		private static var modoVOZ:String = "normal";
		
		/**
		 * Modos do audio com relação ao ControleGeral (mute / normal)
		 */
		private static var estadoSom:String = "normal";
		private static var estadoNarracao:String = "normal";
		
		/**
		 * Inicia (play) o som de um determinado canal
		 * Caso o canal passado como parãmetro exista, será utilizado o mesmo, caso contrário será criado um novo.
		 * @param	_canal		Nome do canal, utilizado para manipular todas as funções de som.
		 * @param	_tipo		Tipo do canal, utilizado para classificar os canais: BGM, SFX ou VOZ.
		 * @param	_audio		Nome do audio na Biblioteca, utilizado para iniciar o objeto de som.
		 * @param	_volume		Volume inicial, volume definido entre 0 e 1.
		 * @param	_vezes		Quantidade de Vezes, quantidade de vezes que o som irá repetir 0, 1, ... n. Usar Infinity para loop.
		 * @param	_espera		Tempo de espera em segundos para o som iniciar.
		 * @return	Boolean		True para sucesso e False para erro.
		 */
		public static function iniciarSom ( _canal:String, _tipo:String = "", _audio:String = "", _volume:Number = 1, _vezes:Number = 1, _espera:Number = 0 ):Boolean {
			//ID do Time Out
			var idTimeOut:uint = 0;
			//Calcula o tempo de espera
			var espera:Number = _espera * 1000;
			//Retorno Padrão
			var retorno:Boolean = false;
			
			//Caso tenha tempo de espera
			if ( espera > 0 ) { 
				//Executa um TimeOut baseado neste tempo e guarda o ID do TimeOut para utilizar ao destruir o canal
				idTimeOut = setTimeout( iniciarSom, espera, _canal, _tipo, _audio, _volume, _vezes );
				timeOutConf[ idTimeOut ] = _canal + "," + _tipo + "," + _audio;
				
			//Caso contrário
			} else {
				try {
					//Caso o canal não exista
					if ( canais[ _canal ] == null ) {
						//Instancia um novo canal
						canais[ _canal ] = new CanalSom( _tipo, _audio, _volume, _vezes );
						
					} else {
						
						//Somente se o _tipo e o _audio forem diferente de vazio
						if ( _tipo != "" && _audio != "" ) {
							//Se o _tipo ou o _audio passados forem diferentes do tipo e audio instanciados no canal
							if ( _tipo != canais[ _canal ].getTipoCanal(  ) || _audio != canais[ _canal ].getNomeAudio(  ) ) {
								//Para o som do canal
								pararSom( _canal );
								//Instancia um novo canal
								canais[ _canal ] = new CanalSom( _tipo, _audio, _volume, _vezes );
								
							}						
						//Caso contrário
						} else {
							//Atribui _tipo e _audio ja contidos no canal
							if ( _tipo == "" ) _tipo = canais[ _canal ].getTipoCanal(  );
							if ( _audio == "" ) _audio = canais[ _canal ].getNomeAudio(  );
							
						}
						
					}
					
					canais[ _canal ].play( 0, _volume, _vezes );
					
					if ( _tipo == TIPO_BGM ) alterarModo( _canal, modoBGM );
					if ( _tipo == TIPO_SFX ) alterarModo( _canal, modoSFX );
					if ( _tipo == TIPO_VOZ ) alterarModo( _canal, modoVOZ );
					
					retorno = true;
					
				} catch ( erro:Error ) {
					//Caso ocorra algum erro, exibe a mensagem de erro
					exibeErro( _canal, "iniciarSom", erro.message );
					retorno = false;
					
				}
			}
			
			return retorno;
			
		}
		
		/**
		 * Inicia (play) o som de vários canais ao mesmo tempo, desde que todos pertençam ao mesmo tipo, por exemplo: BGM, SFX ou VOZ
		 * @param	_tipo		Tipo do canal, utilizado para classificar os canais: BGM, SFX ou VOZ.
		 * @param	_volume		Volume inicial, volume definido entre 0 e 1.
		 * @param	_vezes		Quantidade de Vezes, quantidade de vezes que o som irá repetir 0, 1, ... n. Usar Infinity para loop.
		 * @param	_espera		Tempo de espera em segundos para o som iniciar.
		 * @return	int			Quantidade de canais afetados pela alteração
		 */
		public static function iniciarSomTipo ( _tipo:String, _volume:Number = 1, _vezes:Number = 1, _espera:Number = 0 ):int {
			//Inicia a quantidade em 0
			var qtdCAlterados:int = 0;
			
			//Varre todos os canais
			for ( var _canal:String in canais ) {
				//Se o canal corrente for do memso tipo que o parâmetro _tipo
				if ( canais[ _canal ].getTipoCanal(  ) == _tipo ) {
					//Inicia o som no canal caso não ocorra erros
					if ( iniciarSom( _canal, _tipo, canais[ _canal ].getNomeAudio(  ), _volume, _vezes, _espera ) ) {
						//Incrementa a quantidade
						qtdCAlterados++;
						
					}
					
				}
				
			}
				
			return qtdCAlterados;
		}
		
		/**
		 * Para (stop) o som de um determinado canal
		 * @param	_canal		Nome do canal, utilizado para manipular todas as funções de som.
		 * @return	Boolean		True para sucesso e False para erro.
		 */
		public static function pararSom ( _canal:String ):Boolean {
			//Retorno Padrão
			var retorno:Boolean = false;
			
			try {
				//Caso o canal exista
				if ( canais[ _canal ] != null ) {
					//Para o som do canal
					canais[ _canal ].stop(  );
					
					retorno = true;
				//Caso contrário
				} else {
					//Exibe o erro de canal não instanciado
					exibeErro( _canal, "pararSom", "O Canal não está devidamente instanciado." );
					retorno = false;
					
				}
				
			} catch ( erro:Error ) {
				//Caso ocorra algum erro, exibe a mensagem de erro
				exibeErro( _canal, "pararSom", erro.message );
				retorno = false;
				
			}
			
			return retorno;
			
		}
		
		/**
		 * Para (stop) o som de vários canais ao mesmo tempo, desde que todos pertençam ao mesmo tipo, por exemplo: BGM, SFX ou VOZ
		 * @param	_tipo		Tipo do canal, utilizado para classificar os canais: BGM, SFX ou VOZ.
		 * @return	int			Quantidade de canais afetados pela alteração
		 */
		public static function pararSomTipo ( _tipo:String ):int {
			//Inicia a quantidade em 0
			var qtdCAlterados:int = 0;
			
			//Varre todos os canais
			for ( var _canal:String in canais ) {
				//Se o canal corrente for do memso tipo que o parâmetro _tipo
				if ( canais[ _canal ].getTipoCanal(  ) == _tipo ) {
					//Para o som no canal caso não ocorra erros
					if ( pararSom( _canal ) ) {
						//Incrementa a quantidade
						qtdCAlterados++;
						
					}
					
				}
				
			}
				
			return qtdCAlterados;
		}
		
		/**
		 * Altera o volume do som de um determinado canal
		 * @param	_canal		Nome do canal, utilizado para manipular todas as funções de som.
		 * @param	_volume		Novo volume, volume definido entre 0 e 1.
		 * @return	Boolean		True para sucesso e False para erro.
		 */
		public static function mudarVolume ( _canal:String, _volume:Number ):Boolean {
			//Retorno Padrão
			var retorno:Boolean = false;
			
			try {
				//Caso o canal exista
				if ( canais[ _canal ] != null ) {
					
					var volume:Number = _volume;
					//Caso o _volume menor que 0
					if ( _volume < 0 ) {
						//Define volume em 0
						volume = 0;
						
					}
					//Define o volume do canal
					canais[ _canal ].setVolume( volume );
					
					retorno = true;
				//Caso contrário
				} else {
					//Exibe o erro de canal não instanciado
					exibeErro( _canal, "mudarVolume", "O Canal não está devidamente instanciado." );
					retorno = false;
					
				}				
				
			} catch ( erro:Error ) {
				//Caso ocorra algum erro, exibe a mensagem de erro
				exibeErro( _canal, "mudarVolume", erro.message );
				retorno = false;
				
			}
			
			return retorno;
			
		}
		
		/**
		 * Altera o volume do audio de vários canais ao mesmo tempo, desde que todos pertençam ao mesmo tipo, por exemplo: BGM, SFX ou VOZ
		 * @param	_tipo		Tipo do canal, utilizado para classificar os canais: BGM, SFX ou VOZ.
		 * @param	_volume		Novo volume, volume definido entre 0 e 1.
		 * @return	int			Quantidade de canais afetados pela alteração
		 */
		public static function mudarVolumeTipo ( _tipo:String, _volume:Number ):int {
			//Inicia a quantidade em 0
			var qtdCAlterados:int = 0;
			
			//Varre todos os canais
			for ( var _canal:String in canais ) {
				//Se o canal corrente for do memso tipo que o parâmetro _tipo
				if ( canais[ _canal ].getTipoCanal(  ) == _tipo ) {
					//Muda o volume do som no canal caso não ocorra erros
					if ( mudarVolume( _canal, _volume ) ) {
						//Incrementa a quantidade
						qtdCAlterados++;
						
					}
					
				}
				
			}
				
			return qtdCAlterados;
		}
		
		/**
		 * Pausa o som de um determinado canal
		 * @param	_canal		Nome do canal, utilizado para manipular todas as funções de som.
		 * @return	Boolean		True para sucesso e False para erro.
		 */
		public static function pausarSom ( _canal:String ):Boolean {
			//Retorno Padrão
			var retorno:Boolean = false;
			
			try {
				//Caso o canal exista
				if ( canais[ _canal ] != null ) {
					//Pausa o som do canal
					canais[ _canal ].pause(  );
					
					retorno = true;
				//Caso contrário
				} else {
					//Exibe o erro de canal não instanciado
					exibeErro( _canal, "pausarSom", "O Canal não está devidamente instanciado." );
					retorno = false;
					
				}
				
			} catch ( erro:Error ) {
				//Caso ocorra algum erro, exibe a mensagem de erro
				exibeErro( _canal, "pausarSom", erro.message );
				retorno = false;
				
			}
			
			return retorno;
			
		}
		
		/**
		 * Pausa o som de vários canais ao mesmo tempo, desde que todos pertençam ao mesmo tipo, por exemplo: BGM, SFX ou VOZ
		 * @param	_tipo		Tipo do canal, utilizado para classificar os canais: BGM, SFX ou VOZ.
		 * @return	int			Quantidade de canais afetados pela alteração
		 */
		public static function pausarSomTipo ( _tipo:String ):int {
			//Inicia a quantidade em 0
			var qtdCAlterados:int = 0;
			
			//Varre todos os canais
			for ( var _canal:String in canais ) {
				//Se o canal corrente for do memso tipo que o parâmetro _tipo
				if ( canais[ _canal ].getTipoCanal(  ) == _tipo ) {
					//Pausa som no canal caso não ocorra erros
					if ( pausarSom( _canal ) ) {
						//Incrementa a quantidade
						qtdCAlterados++;
						
					}
					
				}
				
			}
				
			return qtdCAlterados;
		}
		
		/**
		 * Resume o som de um determinado canal
		 * @param	_canal		Nome do canal, utilizado para manipular todas as funções de som.
		 * @return	Boolean		True para sucesso e False para erro.
		 */
		public static function resumirSom ( _canal:String ):Boolean {
			//Retorno Padrão
			var retorno:Boolean = false;
			
			try {
				//Caso o canal exista
				if ( canais[ _canal ] != null ) {
					//Resume o som do canal
					canais[ _canal ].resume(  );
					
					retorno = true;
				//Caso contrário
				} else {
					//Exibe o erro de canal não instanciado
					exibeErro( _canal, "resumirSom", "O Canal não está devidamente instanciado." );
					retorno = false;
					
				}	
				
			} catch ( erro:Error ) {
				//Caso ocorra algum erro, exibe a mensagem de erro
				exibeErro( _canal, "resumirSom", erro.message );
				retorno = false;
				
			}
			
			return retorno;
			
		}
		
		/**
		 * Resume o som de vários canais ao mesmo tempo, desde que todos pertençam ao mesmo tipo, por exemplo: BGM, SFX ou VOZ
		 * @param	_tipo		Tipo do canal, utilizado para classificar os canais: BGM, SFX ou VOZ.
		 * @return	int			Quantidade de canais afetados pela alteração
		 */
		public static function resumirSomTipo ( _tipo:String ):int {
			//Inicia a quantidade em 0
			var qtdCAlterados:int = 0;
			
			//Varre todos os canais
			for ( var _canal:String in canais ) {
				//Se o canal corrente for do memso tipo que o parâmetro _tipo
				if ( canais[ _canal ].getTipoCanal(  ) == _tipo ) {
					//Resume som no canal caso não ocorra erros
					if ( resumirSom( _canal ) ) {
						//Incrementa a quantidade
						qtdCAlterados++;
						
					}
					
				}
				
			}
				
			return qtdCAlterados;
		}
		
		/**
		 * Altera o modo do som de um determinado canal
		 * @param	_canal		Nome do canal, utilizado para manipular todas as funções de som.
		 * @param	_modo		Modo do som, "mute" ou "normal"
		 * @return	Boolean		True para sucesso e False para erro.
		 */
		public static function alterarModo ( _canal:String, _modo:String = "normal" ):Boolean {
			//Retorno Padrão
			var retorno:Boolean = false;
			
			try {
				//Caso o canal exista
				if ( canais[ _canal ] != null ) {
					//Caso o modo seja Normal
					if ( _modo == "normal" ) {
						//Define o som como Normal
						canais[ _canal ].setMute( false );
					//Caso o modo seja Mudo
					} else if ( _modo == "mute" ) {
						//Define o som como Mudo
						canais[ _canal ].setMute( true );
						
					}
					
					retorno = true;
				//Caso contrário
				} else {
					//Exibe o erro de canal não instanciado
					exibeErro( _canal, "alterarModo", "O Canal não está devidamente instanciado." );
					retorno = false;
					
				}
				
			} catch ( erro:Error ) {
				//Caso ocorra algum erro, exibe a mensagem de erro
				exibeErro( _canal, "alterarModo", erro.message );
				retorno = false;
				
			}		
			
			return retorno;
			
		}
		
		/**
		 * Altera o modo do som de vários canais ao mesmo tempo, desde que todos pertençam ao mesmo tipo, por exemplo: BGM, SFX ou VOZ
		 * @param	_tipo		Tipo do canal, utilizado para classificar os canais: BGM, SFX ou VOZ.
		 * @param	_modo		Modo do som, "mute" ou "normal"
		 * @return	int			Quantidade de canais afetados pela alteração
		 */
		public static function alterarModoTipo ( _tipo:String, _modo:String = "normal" ):int {
			//Inicia a quantidade em 0
			var qtdCAlterados:int = 0;			 
			//Caso o modo seja Normal ou Mudo
			if ( _modo == "normal" || _modo == "mute" ) {
				
				/**
				 * Modifica o estado do canal
				 */
				//Caso BGM
				if ( _tipo == TIPO_BGM ) {
					//Altera entre Mute ou Normal
					modoBGM = _modo;
					if ( _modo == "mute" && modoSFX == _modo ) estadoSom = _modo;
					else if ( _modo == "normal" && modoSFX == _modo ) estadoSom = _modo;
				//Caso SFX
				} else if ( _tipo == TIPO_SFX ) {
					//Altera entre Mute ou Normal
					modoSFX = _modo;
					if ( _modo == "mute" && modoBGM == _modo ) estadoSom = _modo;
					else if ( _modo == "normal" && modoBGM == _modo ) estadoSom = _modo;
				//Caso VOZ
				} else if ( _tipo == TIPO_VOZ ) {
					//Altera entre Mute ou Normal
					modoVOZ = _modo;
					estadoNarracao = modoVOZ;
					
				}
				
				//Varre todos os canais
				for ( var _canal:String in canais ) {
					//Se o canal corrente for do memso tipo que o parâmetro _tipo
					if ( canais[ _canal ].getTipoCanal(  ) == _tipo ) {
						//Altera o modo do som no canal caso não ocorra erros
						if ( alterarModo( _canal, _modo ) ) {
							//Incrementa a quantidade
							qtdCAlterados++;
							
						}
						
					}
					
				}
				
			}
				
			return qtdCAlterados;
		}
		
		/**
		 * Retorna o estado do canal
		 * @param	_canal		Nome do canal, utilizado para manipular todas as funções de som.
		 * @return	String 		Estado do canal:	mute, normal e off (caso ocorra erro)
		 */
		public static function getEstadoCanal ( _canal:String ):String {
			//Retorno Padrão
			var retorno:String = "";
			
			try {
				//Caso o canal exista
				if ( canais[ _canal ] != null ) {
					//Retorna o estado do Canal
					retorno = canais[ _canal ].getEstado(  );
				//Caso contrário
				} else {
					//Exibe o erro de canal não instanciado
					exibeErro( _canal, "getEstadoCanal", "O Canal não está devidamente instanciado." );
					retorno = "off";
				}
				
			} catch ( erro:Error ) {
				//Caso ocorra algum erro, exibe a mensagem de erro
				exibeErro( _canal, "getEstadoCanal", erro.message );
				retorno = "off";
				
			}
			
			return retorno;
			
		}
		
		/**
		 * Retorna o estado do audio
		 * @param	_tipoAudio	Tipo utilizado no controle geral, deve ser "som" ou "narracao".
		 * @return	String 		Estado do canal:	mute, normal e off (caso ocorra erro)
		 */
		public static function getEstadoAudio ( _tipoAudio:String ):String {
			//Retorno Padrão
			var retorno:String = "";
			
			try {
				//Caso o _tipoAudio seja "som"
				if ( _tipoAudio == "som" ) {
					//Retorna o estadoSom
					retorno = estadoSom;
				//Caso o _tipoAudio seja "narracao"
				} else if ( _tipoAudio == "narracao" ) {
					//Retorna o estadoNarracao
					retorno = estadoNarracao;
				//Caso contrário
				} else {
					//Exibe o erro de canal não instanciado
					exibeErro( "geral", "getEstadoAudio", "O _tipoAudio deve ser \"som\" ou \"narracao\"!" );
					retorno = "off";
				}
				
			} catch ( erro:Error ) {
				//Caso ocorra algum erro, exibe a mensagem de erro
				exibeErro( "geral", "getEstadoAudio", erro.message );
				retorno = "off";
				
			}
			
			return retorno;
			
		}
		
		/**
		 * Retorna a duração do audio sendo executado no canal
		 * @param	_canal		Nome do canal, utilizado para manipular todas as funções de som.
		 * @return	Number		Duração do audio sendo executado (não leva em consideração o tempo de espera)
		 */
		public static function getDuracaoAudio( _canal:String ):Number {
			//Retorno Padrão
			var retorno:Number = 0;
			
			try {
				//Caso o canal exista
				if ( canais[ _canal ] != null ) {
					//Retorna a duração do canal
					retorno = canais[ _canal ].getTempoAudio(  );
					
				//Caso contrário
				} else {
					//Exibe o erro de canal não instanciado
					exibeErro( _canal, "getDuracaoAudio", "O Canal não está devidamente instanciado." );
					retorno = 0;
				}
				
			} catch ( erro:Error ) {
				//Caso ocorra algum erro, exibe a mensagem de erro
				exibeErro( _canal, "getDuracaoAudio", erro.message );
				retorno = 0;
				
			}
			
			return retorno;
			
		}
		
		/**
		 * Destroi o canal para que possa ser feito o Garbage Collector
		 * @param	_canal		Nome do canal, utilizado para manipular todas as funções de som.
		 * @return	Boolean
		 */
		public static function destruirCanal ( _canal:String ):Boolean {
			//Retorno Padrão
			var retorno:Boolean = false;
			//arrConf
			var arrConf:Array;
			var id:uint = 0;
			
			try {
				
				//varre todos os timeouts
				for ( var _id:String in timeOutConf ) {
					
					id = uint( _id );
					
					//retorna o canal e o tipo
					arrConf = timeOutConf[ id ].split( "," );
					
					if ( arrConf[ 0 ] == _canal ) {
						
						clearTimeout( uint( id ) );
						trace( "Removido o Time Out '" + id + "' utilizado no som '" + arrConf[ 2 ] + "' do canal '" + arrConf[ 0 ] + "'" );
						delete timeOutConf[ id ];
						
						if ( canais[ _canal ] != null ) {
							canais[ _canal ].destroy(  );
							canais[ _canal ] = null;
							delete canais[ _canal ];
							
							trace( "Destruido o canal '" + arrConf[ 0 ] + "'" );
						}
						
					}
					
				}
				
				//Varre todos os canais
				for ( var _canalAux:String in canais ) {
					//Se o canal corrente for do memso tipo que o parâmetro _tipo
					if ( _canalAux == _canal ) {
						//Destroi o canal
						if ( canais[ _canal ] != null ) {
							canais[ _canal ].destroy(  );
							canais[ _canal ] = null;
							delete canais[ _canal ];
							
							trace( "Destruido o canal '" + _canal + "'" );
						}
						
					}
					
				}
				
				retorno = true;
				
			} catch ( erro:Error ) {
				
				//Caso ocorra algum erro, exibe a mensagem de erro
				exibeErro( _canal, "destruirCanal", erro.message );
				retorno = false;
				
			}
			
			return retorno;
			
		}
		
		/**
		 * Destroi os canais que pertencem ao mesmo tipo para que possa ser feito o Garbage Collector
		 * @param	_tipo		Tipo do canal, utilizado para classificar os canais: BGM, SFX ou VOZ.
		 * @return	int			Quantidade de canais afetados pela alteração
		 */
		public static function destruirCanalTipo ( _tipo:String ):int {
			//Inicia a quantidade em 0
			var qtdCAlterados:int = 0;			 
			//arrConf
			var arrConf:Array;
			var id:uint = 0;
			
			//varre todos os timeouts
			for ( var _id:String in timeOutConf ) {
				
				id = uint( _id );
				
				//retorna o canal e o tipo
				arrConf = timeOutConf[ id ].split( "," );
				
				if ( arrConf[ 1 ] == _tipo ) {
					
					//Destroi o canal
					if ( destruirCanal( arrConf[ 0 ] ) ) {
						//Incrementa a quantidade
						qtdCAlterados++;
						
					}
					
				}
				
			}
			
			//Varre todos os canais
			for ( var _canal:String in canais ) {
				//Se o canal corrente for do memso tipo que o parâmetro _tipo
				if ( canais[ _canal ].getTipoCanal(  ) == _tipo ) {
					//Destroi o canal
					if ( destruirCanal( _canal ) ) {
						//Incrementa a quantidade
						qtdCAlterados++;
						
					}
					
				}
				
			}
			
			return qtdCAlterados;
			
		}
		
		/**
		 * Exibe a mensagem caso ocorra erro na execução de algum comando
		 * @param	_canal		Nome do canal, utilizado para manipular todas as funções de som.
		 * @param	_acao		Ação que esta sendo executada, definida pelo nome da função
		 * @param	_msg		Mensagem de erro
		 */
		private static function exibeErro ( _canal:String, _acao:String, _msg:String ):void {
			//Monta a mensagem de erro
			msgErro = "Erro ao Executar '" + _acao + "' no Canal '" + _canal + "': " + _msg;
			//Exibe a mesma no console
			trace( msgErro );
			
		}
		
	}

}