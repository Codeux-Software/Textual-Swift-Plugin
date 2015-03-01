
/* We create a class that inherits from NSObject so we need Foundation. */
import Foundation

/* As Textual creates a new instance of our primary class when the plugin
loads, it must inherit NSObject to allow proper initialization. */
/* THOPluginProtocol is the protocol available for plugin specific callbacks.
It is appended to our new class object to inform Swift that we conform to it. */
class TPI_SwiftPluginExample: NSObject, THOPluginProtocol
{
	func subscribedServerInputCommands() -> [AnyObject]!
	{
		/* Accept all incoming server data corresponding to the
		commands PRIVMSG and NOTICE. The plugin will perform
		different actions for each value. */
		
		return ["privmsg", "notice"]
	}
	
	func didReceiveServerInputOnClient(client: IRCClient!, senderInformation senderDict: [NSObject : AnyObject]!, messageInformation messageDict: [NSObject : AnyObject]!)
	{
		/* Swift provides a very powerful switch statement so
		it is easier to use that for identifying commands than
		using an if statement if more than the two are added. */
		let commandValue = (messageDict[THOPluginProtocolDidReceiveServerInputMessageCommandAttribute] as String)

		switch (commandValue) {
			case "PRIVMSG":
				self.handleIncomingPrivateMessageCommand(client, senderDict: senderDict, messageDict: messageDict)
			case "NOTICE":
				self.handleIncomingNoticeCommand(client, senderDict: senderDict, messageDict: messageDict)
			default:
				return;
		}
	}
	
	func handleIncomingPrivateMessageCommand(client: IRCClient!, senderDict: [NSObject : AnyObject]!, messageDict: [NSObject : AnyObject]!)
	{
		/* Get message sequence of incoming message. */
		let messageReceived = (messageDict[THOPluginProtocolDidReceiveServerInputMessageSequenceAttribute] as String)
		
		let messageParamaters = (messageDict[THOPluginProtocolDidReceiveServerInputMessageParamatersAttribute] as Array<String>)
		
		/* Get channel that message was sent from. */
		/* The first paramater of the PRIVMSG command is always
		the channel the message was targetted to. */
		let senderChannel = client.findChannel(messageParamaters[0])
		
		/* Do not accept private messages. */
		if senderChannel.isPrivateMessage {
			return;
		}
		
		/* Get sender of message. */
		let messageSender = (senderDict[THOPluginProtocolDidReceiveServerInputSenderNicknameAttribute] as String)
		
		/* Ignore this user, he's kind of a jerk. :-( */
		if messageSender.hasPrefix("Alex") {
			return;
		}
		
		/* Compare it against a specific value. */
		if (messageReceived == "do you know what time it is?" ||
			messageReceived == "does anybody know what time it is?")
		{
			/* Format message. */
			let formattedString = (messageSender + " the time where I am is: " + self.formattedDateTimeString());
			
			/* Invoke the client on the main thread when sending. */
			self.performBlockOnMainThread({
				client.sendPrivmsg(formattedString, toChannel: senderChannel)
			});
		}
	}
	
	func handleIncomingNoticeCommand(client: IRCClient!, senderDict: [NSObject : AnyObject]!, messageDict: [NSObject : AnyObject]!)
	{
		// Not implemented.
	}
	
	/* Support a new command in text field. */
	func subscribedUserInputCommands() -> [AnyObject]!
	{
		return ["datetime"]
	}

	func userInputCommandInvokedOnClient(client: IRCClient!, commandString: String!, messageString: String!)
	{
		let formattedString = ("The current time is: " + self.formattedDateTimeString());

		self.performBlockOnMainThread({
			client.sendPrivmsg(formattedString, toChannel:self.masterController().mainWindow.selectedChannel)
		});
	}
	
	/* Helper functions. */
	func formattedDateTimeString() -> (String)
	{
		let dateFormatter = NSDateFormatter()
		
		dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
		dateFormatter.timeStyle = NSDateFormatterStyle.FullStyle
		
		let formattedDate = dateFormatter.stringFromDate(NSDate())
		
		return formattedDate
	}
}
