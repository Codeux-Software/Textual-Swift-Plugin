
/* We create a class that inherits from NSObject so we need Foundation. */
import Foundation

/* As Textual creates a new instance of our primary class when the plugin
loads, it must inherit NSObject to allow proper initialization. */
/* THOPluginProtocol is the protocol available for plugin specific callbacks.
It is appended to our new class object to inform Swift that we conform to it. */

class TPI_SwiftPluginExample: NSObject, THOPluginProtocol
{
	var subscribedServerInputCommands: [AnyObject]! {
		get {
			return ["privmsg", "notice"]
		}
	}

	func didReceiveServerInput(inputObject: THOPluginDidReceiveServerInputConcreteObject!, onClient client: IRCClient!)
	{
		/* Swift provides a very powerful switch statement so
		it is easier to use that for identifying commands than
		using an if statement if more than the two are added. */

		NSLog("%@ %@", inputObject.messageCommand, inputObject.messageParamaters)

		switch (inputObject.messageCommand) {
			case "PRIVMSG":
				self.handleIncomingPrivateMessageCommand(inputObject, onClient: client)
			case "NOTICE":
				self.handleIncomingNoticeCommand(inputObject, onClient: client)
			default:
				return
		}
	}

	func handleIncomingPrivateMessageCommand(inputObject: THOPluginDidReceiveServerInputConcreteObject!, onClient client: IRCClient!)
	{
		/* Get message sequence of incoming message. */
		let messageReceived = (inputObject.messageSequence as String)

		let messageParamaters = (inputObject.messageParamaters as! Array<String>)

		/* Get channel that message was sent from. */
		/* The first paramater of the PRIVMSG command is always
		the channel the message was targetted to. */
		let senderChannel = client.findChannel(messageParamaters[0])

		/* Do not accept private messages. */
		if senderChannel.isPrivateMessage {
			return
		}

		/* Get sender of message. */
		let messageSender = (inputObject.senderNickname as String)

		/* Ignore this user, he's kind of a jerk. :-( */
		if messageSender.hasPrefix("Alex") {
			return
		}

		/* Compare it against a specific value. */
		if (messageReceived == "do you know what time it is?" ||
			messageReceived == "does anybody know what time it is?")
		{
			/* Format message. */
			let formattedString = (messageSender + ", the time where I am is: " + self.formattedDateTimeString())

			/* Invoke the client on the main thread when sending. */
			self.performBlockOnMainThread({
				client.sendPrivmsg(formattedString, toChannel: senderChannel)
			})
		}
	}

	func handleIncomingNoticeCommand(inputObject: THOPluginDidReceiveServerInputConcreteObject!, onClient client: IRCClient!)
	{
		// Not implemented.
	}

	/* Support a new command in text field. */
	var subscribedUserInputCommands: [AnyObject]! {
		get {
			return ["datetime"]
		}
	}

	func userInputCommandInvokedOnClient(client: IRCClient!, commandString: String!, messageString: String!)
	{
		let formattedString = ("The current time is: " + self.formattedDateTimeString())

		let mainWindow = self.masterController().mainWindow;

		self.performBlockOnMainThread({
			client.sendPrivmsg(formattedString, toChannel:mainWindow.selectedChannel)
		})
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
