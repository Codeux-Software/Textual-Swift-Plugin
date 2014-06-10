
import Foundation

class TPI_PreferencePaneExample: NSObject, THOPluginProtocol
{
	func pluginSupportsUserInputCommands() -> (NSArray)
	{
		return ["swift"]
	}

	func messageSentByUser(client: IRCClient, message: String, command: String)
	{
		let dateFormatter = NSDateFormatter()

		dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
		dateFormatter.timeStyle = NSDateFormatterStyle.FullStyle

		let formattedDate = dateFormatter.stringFromDate(NSDate())
		let formattedString = ("The current time is: " + formattedDate)

		client.iomt().sendPrivmsgToSelectedChannel(formattedString)
	}
}
