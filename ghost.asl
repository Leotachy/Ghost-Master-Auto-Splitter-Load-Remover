/*
 * Created by Woitek1993
 * https://discord.gg/EAvtUbD5
 * This script only supports Ghost Master version with bonus scenario. Currenly doesn't work on piracy protected copies.
*/

state ("ghost")
{
	bool ProgressBarMenu : "ghost.exe", 0x551E18;
	uint score_interface : "ghost.exe", 0x54EBB4;
	uint main_screen_interface : "ghost.exe", 0x54EBEC;
	uint ouija_board_interface : "ghost.exe", 0x54EBF0;
	uint final_haunters : "ghost.exe", 0x569AA4, 0x4;
	int game_mode : "ghost.exe", 0x55019C;
	int mortals_fleed : "ghost.exe", 0x550170;
	int mortals_insane : "ghost.exe", 0x55016C;
}


state ("CompleteEdition") //In case a user is running the Complete Edition version
{
	bool ProgressBarMenu : "CompleteEdition.exe", 0x551E18;
	uint score_interface : "CompleteEdition.exe", 0x54EBB4;
	uint main_screen_interface : "CompleteEdition.exe", 0x54EBEC;
	uint ouija_board_interface : "CompleteEdition.exe", 0x54EBF0;
	uint final_haunters : "CompleteEdition.exe", 0x569AA4, 0x4;
	int game_mode : "CompleteEdition.exe", 0x55019C;
	int mortals_fleed : "CompleteEdition.exe", 0x550170;
	int mortals_insane : "CompleteEdition.exe", 0x55016C;
}


init
{
	//no versions checks I know of...
	//variable which tells if the timer is currently paused
	vars.timerPaused = true; 
	
	//variable which tells if the Ouija Board "OK" button was triggered
	vars.OuijaOkClicked = false;
	vars.last_script = false;
	
	//clear variables...
	current.ouija_board_interface = 0;
	old.ouija_board_interface = 0;
}

startup
{
	vars.script_name_array = 0;

	//variable which tells if the timer is currently paused
	vars.timerPaused = true; 
	
	//variable which tells if the Ouija Board "OK" button was triggered
	vars.OuijaOkClicked = false;

	//
	vars.last_script = false;
}

start 
{
	/*
	 * Timer Start function
	 * if the timer is already running and Ouija Board's "OK" button is triggered, then restart and run the timer
	 */
	if (vars.timerPaused == false && vars.OuijaOkClicked == true) {
		return true;
	}
}

split {
	/*
	 * Splits only occur when the current score interface is NULL(uninitialized)
	 * and when the old one was initialized (old.score_interface > 0)
	 */
	 
	if ( ( (current.score_interface == 0) &&
	     (current.score_interface != old.score_interface) ) || 
		( (current.final_haunters != old.final_haunters) && ( (current.mortals_fleed > 0) || (current.mortals_insane > 0) ) && (vars.last_script == false) ) ) 
	{
		if ( (current.final_haunters != old.final_haunters) && ( (current.mortals_fleed > 0) || (current.mortals_insane > 0) ) && (vars.last_script == false)   )
		{
			vars.last_script = true;
		}
		return true;
	}
}

reset
{
	//if you go back to main menu screen, then it resets.
	if ( (current.main_screen_interface == 0) &&
	     (current.main_screen_interface != old.main_screen_interface) && (current.game_mode != 7) )
	{
		vars.timerPaused = true; 
		vars.OuijaOkClicked = false; 
		vars.check_final = false;
		vars.is_final_split = false;
		vars.last_script = false;
		return true;
	}	
}

update
{	
	/*
	 * Ouija board is registered when the current Ouija interface is NULL(uninitialized)
	 * and if the old value of the Ouija interface is initialized (old.ouija_board_interface > 0)
	 */

    if ( 
	(current.ouija_board_interface == 0) &&
	(current.ouija_board_interface != old.ouija_board_interface) )
	{
		vars.OuijaOkClicked = true;
	}
	
	/* Timer is paused only when Progress Bar Menu is initialized.
	 * Game uses a static boolean to determine if the menu is initialized.
	 */
	vars.timerPaused = (current.ProgressBarMenu == true);
	
}

isLoading
{	
	//Returns state of loading. In our case, paused value.
	return vars.timerPaused;
}

exit
{
	//Pause the timer, if the game is closed...
	timer.IsGameTimePaused = true;
}
