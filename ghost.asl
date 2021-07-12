/*
 * Created by Woitek1993
 * https://discord.gg/EAvtUbD5
 * This script only supports Ghost Master version with bonus scenario
*/

state ("ghost")
{
	bool ProgressBarMenu : "ghost.exe", 0x551E18;
	uint score_interface : "ghost.exe", 0x54EBB4;
	uint team_selection_interface : "ghost.exe", 0x54EBC4;
	uint main_screen_interface : "ghost.exe", 0x54EBEC;
	uint ouija_board_interface : "ghost.exe", 0x54EBF0;
	bool plasm_bar_interface_visible : "ghost.exe", 0x54EB40, 0x4E4;
	int game_mode : "ghost.exe", 0x55019C;
	uint final_haunters : "ghost.exe", 0x569AA4, 0x4;
	bool render_game : "ghost.exe", 0x535D68;
}


state ("CompleteEdition") //In case a user is running the Complete Edition version
{
	bool ProgressBarMenu : "CompleteEdition.exe", 0x551E18;
	uint score_interface : "CompleteEdition.exe", 0x54EBB4;
	uint team_selection_interface : "CompleteEdition.exe", 0x54EBC4;
	uint main_screen_interface : "CompleteEdition.exe", 0x54EBEC;
	uint ouija_board_interface : "CompleteEdition.exe", 0x54EBF0;
	bool plasm_bar_interface_visible : "CompleteEdition.exe", 0x54EB40, 0x4E4;
	int game_mode : "CompleteEdition.exe", 0x55019C;
	uint final_haunters : "CompleteEdition.exe", 0x569AA4, 0x4;
	bool render_game : "ghost.exe", 0x535D68;
}


init
{
	//no versions checks I know of...
	//variable which tells if the timer is currently paused
	vars.timerPaused = true; 
	
	//variable which tells if the Ouija Board "OK" button was triggered
	vars.OuijaOkClicked = false; 
	
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
		( (current.final_haunters != old.final_haunters) && (current.render_game == true)  ) )
	{
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
	vars.timerPaused = (
					   (current.ProgressBarMenu == true) ||
					   ( (current.team_selection_interface == 0) &&
						 (current.team_selection_interface != old.team_selection_interface) &&
						 (current.plasm_bar_interface_visible == false) ) );
	
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
