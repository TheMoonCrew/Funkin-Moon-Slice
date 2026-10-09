package funkin.ui.debug.scripteditor;

#if (FEATURE_SCRIPT_EDITOR && FEATURE_HAXEUI)
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.events.MouseEvent;
#end

#if (FEATURE_SCRIPT_EDITOR && FEATURE_HAXEUI)
@:build(haxe.ui.ComponentBuilder.build('assets/exclude/ui/editors/script-editor/dialogs/script-name.xml'))
class ScriptNameDialog extends Dialog
{
  static final NAME_PATTERN:EReg = ~/^[A-Za-z0-9_\-]+$/;

  public var onConfirm:Null<String->Void> = null;

  public function new(kindLabel:String)
  {
    super();

    destroyOnClose = true;

    nameHeader.text = 'Name of the new ' + kindLabel;

    nameInput.registerEvent(haxe.ui.events.KeyboardEvent.KEY_DOWN, function(event:haxe.ui.events.KeyboardEvent):Void
    {
      if (event.keyCode == 13) confirm();
    });

    haxe.ui.Toolkit.callLater(() ->
    {
      nameInput.focus = true;
    });
  }

  function confirm():Void
  {
    var text:String = nameInput.text != null ? StringTools.trim(nameInput.text) : '';

    if (!NAME_PATTERN.match(text))
    {
      nameError.text = 'Use only letters, numbers, - and _ (no spaces).';
      return;
    }

    var callback:Null<String->Void> = onConfirm;

    hideDialog(DialogButton.OK);

    if (callback != null) callback(text);
  }

  @:bind(nameCreate, MouseEvent.CLICK)
  function onNameCreateClick(_):Void
  {
    confirm();
  }

  @:bind(nameCancel, MouseEvent.CLICK)
  function onNameCancelClick(_):Void
  {
    hideDialog(DialogButton.CANCEL);
  }
}
#end
