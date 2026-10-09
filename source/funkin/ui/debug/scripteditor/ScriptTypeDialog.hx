package funkin.ui.debug.scripteditor;

#if (FEATURE_SCRIPT_EDITOR && FEATURE_HAXEUI)
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

typedef ScriptTypeEntry =
{
  var id:String;
  var label:String;
  var description:String;

  /** Imports colocados no topo do script. */
  var imports:Array<String>;

  /** Classe base do `class Nome extends <base>`. */
  var base:String;

  /** Se o construtor passa o nome: super("Nome"). */
  var passName:Bool;

  /** Metodos `public override function` que entram vazios no template. */
  var hooks:Array<String>;
}
#end

#if (FEATURE_SCRIPT_EDITOR && FEATURE_HAXEUI)
@:build(haxe.ui.ComponentBuilder.build('assets/exclude/ui/editors/script-editor/dialogs/script-type.xml'))
class ScriptTypeDialog extends Dialog
{
  public static final LUA_ID:String = 'lua';
  // Tipos de script .hxc. Para mudar import, base ou hooks de um tipo, edite so esta tabela.
  // Module e o unico com template confirmado por voce; os outros usam os caminhos da sua lista,
  // e os imports que nao estavam na lista sao palpite.
  public static final TYPES:Array<ScriptTypeEntry> = [
    {
      id: 'module',
      label: 'Module',
      description: 'Script global: recebe eventos de qualquer lugar do jogo (menu, gameplay, tudo).',
      imports: [
        'funkin.modding.module.Module',
        'flixel.FlxG'
      ],
      base: 'Module',
      passName: true,
      hooks: ['onCreate', 'onUpdate', 'onStateChangeEnd', 'onDestroy']
    },
    {
      id: 'state',
      label: 'Scripted State',
      description: 'State totalmente customizado.',
      imports: ['flixel.FlxG', 'flixel.FlxState'],
      base: 'FlxState',
      passName: false,
      hooks: []
    },
    {
      id: 'substate',
      label: 'Scripted SubState',
      description: 'SubState totalmente customizado.',
      imports: ['flixel.FlxG', 'flixel.FlxSubState'],
      base: 'FlxSubState',
      passName: false,
      hooks: []
    },
    {
      id: 'song',
      label: 'Scripted Song',
      description: 'Comportamento unico para uma musica (cutscenes, logica especial).',
      imports: ['funkin.play.song.Song'],
      base: 'Song',
      passName: true,
      hooks: []
    },
    {
      id: 'character',
      label: 'Scripted Character',
      description: 'Comportamento customizado de personagem (animacoes condicionais, reacoes).',
      imports: ['funkin.play.character.BaseCharacter'],
      base: 'BaseCharacter',
      passName: true,
      hooks: []
    },
    {
      id: 'playable',
      label: 'Scripted Playable Character',
      description: 'Variante para personagens jogaveis, com hooks de gameplay do lado do jogador.',
      imports: ['funkin.ui.freeplay.charselect.PlayableCharacter'],
      base: 'PlayableCharacter',
      passName: true,
      hooks: []
    },
    {
      id: 'stage',
      label: 'Scripted Stage',
      description: 'Logica de palco: props que se movem, reagem a musica, trocam de estado.',
      imports: ['funkin.play.stage.Stage'],
      base: 'Stage',
      passName: true,
      hooks: []
    },
    {
      id: 'level',
      label: 'Scripted Story Level',
      description: 'Comportamento de uma semana/nivel do modo historia.',
      imports: ['funkin.ui.story.Level'],
      base: 'Level',
      passName: true,
      hooks: []
    },
    {
      id: 'songevent',
      label: 'Custom Song Event',
      description: 'Novo tipo de evento de chart que o charter pode colocar na musica.',
      imports: ['funkin.play.event.SongEvent'],
      base: 'SongEvent',
      passName: true,
      hooks: []
    },
    {
      id: 'notekind',
      label: 'Custom Note Kind',
      description: 'Novo tipo de nota (nota que faz efeito especial, etc).',
      imports: ['funkin.play.notes.notekind.NoteKind'],
      base: 'NoteKind',
      passName: true,
      hooks: []
    },
    {
      id: 'dialogue',
      label: 'Dialogue Cutscene',
      description: 'Script de cutscene de dialogo (conversas entre musicas).',
      imports: ['funkin.play.cutscene.dialogue.Conversation'],
      base: 'Conversation',
      passName: true,
      hooks: []
    }
  ];

  public var onPick:Null<String->Void> = null;

  var entries:Array<
    {id:String, label:String, description:String}> = [];

  public function new(includeLua:Bool)
  {
    super();

    destroyOnClose = true;

    if (includeLua)
    {
      entries.push({
        id: LUA_ID,
        label: 'Lua script (.lua)',
        description: 'Script Lua para o mod.'
      });
    }

    for (type in TYPES)
    {
      entries.push({
        id: type.id,
        label: type.label + ' (.hxc)',
        description: type.description
      });
    }

    typeList.dataSource.clear();

    for (entry in entries) typeList.dataSource.add({
      text: entry.label,
      id: entry.id,
      description: entry.description
    });

    typeList.selectedIndex = 0;
    typeDescription.text = entries[0].description;

    typeList.registerEvent(MouseEvent.DBL_CLICK, function(_):Void
    {
      pick();
    });
  }

  function pick():Void
  {
    if (typeList.selectedItem == null) return;

    var id:String = Std.string(typeList.selectedItem.id);
    var callback:Null<String->Void> = onPick;

    hideDialog(DialogButton.OK);

    if (callback != null) callback(id);
  }

  @:bind(typeList, UIEvent.CHANGE)
  function onTypeListChange(_):Void
  {
    if (typeList.selectedItem == null) return;

    typeDescription.text = Std.string(typeList.selectedItem.description);
  }

  @:bind(typeNext, MouseEvent.CLICK)
  function onTypeNextClick(_):Void
  {
    pick();
  }

  @:bind(typeCancel, MouseEvent.CLICK)
  function onTypeCancelClick(_):Void
  {
    hideDialog(DialogButton.CANCEL);
  }

  // ---------- templates ----------

  public static function findType(id:String):Null<ScriptTypeEntry>
  {
    for (type in TYPES)
    {
      if (type.id == id) return type;
    }

    return null;
  }

  /**
   * Nome digitado -> nome de classe valido ("meu-mod_2" vira "MeuMod2").
   */
  public static function toClassName(name:String):String
  {
    var result:String = '';

    for (part in ~/[^A-Za-z0-9]+/g.split(name))
    {
      if (part == '') continue;

      result += part.charAt(0).toUpperCase() + part.substr(1);
    }

    if (result == '') result = 'NewScript';

    if (~/^[0-9]/.match(result)) result = 'Script' + result;

    return result;
  }

  public static function template(id:String, name:String):String
  {
    var type:Null<ScriptTypeEntry> = findType(id);

    if (type == null) type = TYPES[0];

    var cls:String = toClassName(name);
    var out:Array<String> = [];

    for (item in type.imports) out.push('import $item;');

    out.push('');
    out.push('class $cls extends ${type.base}');
    out.push('{');
    out.push('  public function new()');
    out.push('  {');
    out.push(type.passName ? '    super("$name");' : '    super();');
    out.push('  }');

    for (hook in type.hooks)
    {
      out.push('');
      out.push('  public override function $hook(event) {}');
    }

    out.push('}');
    out.push('');

    return out.join('\n');
  }
}
#end
