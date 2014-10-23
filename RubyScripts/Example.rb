# -- Config file definitions
ArgumentDefinitionsFile = File.dirname(__FILE__)+'/build.lifesize.icon.ui.qmlgesturearea.conf'  # -- Defines command line arguments to expect 
$hSettings = Hash.new


$hSettings = sys_settingsParse(ArgumentDefinitionsFile)

