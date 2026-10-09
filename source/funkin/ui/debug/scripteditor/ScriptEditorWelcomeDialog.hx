package funkin.ui.debug.scripteditor;

#if (FEATURE_SCRIPT_EDITOR && FEATURE_HAXEUI)
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

typedef ScriptWelcomeEntry =
{
  var label:String;
  var path:String;
}
#end

#if (FEATURE_SCRIPT_EDITOR && FEATURE_HAXEUI)
@:build(haxe.ui.ComponentBuilder.build('assets/exclude/ui/editors/script-editor/dialogs/welcome.xml'))
class ScriptEditorWelcomeDialog extends Dialog
{
  public static final LUA_TEMPLATE:String = '-- New Lua script\n\nfunction onCreate()\n  \nend\n';

  /**
   * Template .hxc padrao (Module). Vem do ScriptTypeDialog, que e a unica fonte dos templates:
   *
   * import funkin.modding.module.Module;
   * import flixel.FlxG;
   *
   * class NewScript extends Module
   * {
   *   public function new()
   *   {
   *     super("NewScript");
   *   }
   *
   *   public override function onCreate(event) {}
   *   public override function onUpdate(event) {}
   *   public override function onStateChangeEnd(event) {}
   *   public override function onDestroy(event) {}
   * }
   *
   * Para um nome escolhido pelo usuario, use ScriptTypeDialog.template(tipo, nome).
   */
  public static var HXC_TEMPLATE(get, never):String;

  static function get_HXC_TEMPLATE():String
  {
    return ScriptTypeDialog.template('module', 'NewScript');
  }

  public var onNewLua:Null<Void->Void> = null;
  public var onNewHxc:Null<Void->Void> = null;
  public var onOpenFolder:Null<Void->Void> = null;
  public var onRefresh:Null<Void->Void> = null;
  public var onOpenScript:Null<String->Void> = null;

  var scripts:Array<ScriptWelcomeEntry>;

  public function new(scripts:Array<ScriptWelcomeEntry>)
  {
    super();

    this.scripts = scripts;
    destroyOnClose = true;

    welcomeScriptList.registerEvent(MouseEvent.DBL_CLICK, function(_):Void
    {
      openSelectedScript();
    });

    renderScripts();

    // o editor desfoca tudo no create(); isto roda depois e deixa o campo de pesquisa pronto para digitar
    haxe.ui.Toolkit.callLater(() ->
    {
      welcomeFilter.focus = true;
    });
  }

  public function setScripts(entries:Array<ScriptWelcomeEntry>):Void
  {
    scripts = entries;

    renderScripts();
  }

  function renderScripts():Void
  {
    var filter:String = welcomeFilter.text != null ? welcomeFilter.text.toLowerCase() : '';
    var shown:Int = 0;

    welcomeScriptList.dataSource.clear();

    for (entry in scripts)
    {
      if (filter != '' && entry.label.toLowerCase().indexOf(filter) < 0) continue;

      welcomeScriptList.dataSource.add({
        text: entry.label,
        path: entry.path
      });

      shown++;
    }

    welcomeScriptCount.text = shown + (shown == 1 ? ' script' : ' scripts');
  }

  function openSelectedScript():Void
  {
    if (welcomeScriptList.selectedItem == null) return;

    var path:String = Std.string(welcomeScriptList.selectedItem.path);
    var callback:Null<String->Void> = onOpenScript;

    hideDialog(DialogButton.CANCEL);

    if (callback != null) callback(path);
  }

  function finish(callback:Null<Void->Void>):Void
  {
    hideDialog(DialogButton.CANCEL);

    if (callback != null) callback();
  }

  @:bind(welcomeFilter, UIEvent.CHANGE)
  function onWelcomeFilterChange(_):Void
  {
    renderScripts();
  }

  @:bind(welcomeNewLua, MouseEvent.CLICK)
  function onWelcomeNewLuaClick(_):Void
  {
    finish(onNewLua);
  }

  @:bind(welcomeNewHxc, MouseEvent.CLICK)
  function onWelcomeNewHxcClick(_):Void
  {
    finish(onNewHxc);
  }

  @:bind(welcomeOpenFolder, MouseEvent.CLICK)
  function onWelcomeOpenFolderClick(_):Void
  {
    finish(onOpenFolder);
  }

  @:bind(welcomeRefresh, MouseEvent.CLICK)
  function onWelcomeRefreshClick(_):Void
  {
    var callback:Null<Void->Void> = onRefresh;

    if (callback != null) callback();
  }
}
#end
