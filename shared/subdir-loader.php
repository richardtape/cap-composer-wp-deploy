<?php

	/**
	 * Plugin Name: MU plugins subdirectory loader
	 * Plugin URI: http://code.ctlt.ubc.ca
	 * Description: Enables MU plugins to be loaded from subdirectories of the WPMU_PLUGINS folder
	 * Version: 0.1
	 * Author: iamfriendly, CTLT
	 * Author URI: http://ubc.ca/
	 *
	 */
	
	class CTLT_Load_MU_Plugins_In_SubDir
	{

		// The transient name
		static $transientName = 'mu_plugins_in_sub_dir';

		/**
		 * Set up our actions and filters
		 *
		 * @author Richard Tape <@richardtape>
		 * @package CTLT_Load_MU_Plugins_In_SubDir
		 * @since 1.0
		 * @param null
		 * @return null
		 */
		
		public function __construct()
		{

			// Load the plugins and clear transient if we're on the plugins' dashboard page
			add_action( 'muplugins_loaded', array( $this, 'muplugins_loaded__requirePlugins' ) );

			// Adjust the MU plugins list table to show which plugins are MU-subdirectories
			add_action( 'after_plugin_row_subdir-loader.php', array( $this, 'after_plugin_row__addRows' ) );

		}/* __construct() */


		/**
		 * Will clear cache when visiting the plugin page in /wp-admin/.
		 * Will also clear cache if a previously detected mu-plugin was deleted.
		 *
		 * @author Richard Tape <@richardtape>
		 * @package CTLT_Load_MU_Plugins_In_SubDir
		 * @since 1.0
		 * @param null
		 * @return (array) $plugins - an array of plugins in sub directories in the WPMU plugins dir
		 */
		
		public static function WPMUPluginFilesInSubDirs()
		{

			// Do we have a pre-existing cache of the plugins? This checks in %prefix%_sitemeta
			$plugins = get_site_transient( static::$transientName );

			// If we do have a cache, let's check the plugins still exist
			if( $plugins !== false )
			{

				foreach( $plugins as $pluginFile )
				{

					if( !is_readable( WPMU_PLUGIN_DIR . '/' . $pluginFile ) )
					{

						$plugins = false;
						break;

					}

				}

			}

			if( $plugins !== false ){
				return $plugins;
			}


			// Check we have access to get_plugins()
			if( !function_exists( 'get_plugins' ) ) {
				require ABSPATH . 'wp-admin/includes/plugin.php';
			}

			// Start fresh
			$plugins = array();

			foreach( get_plugins( '/../mu-plugins' ) as $pluginFile => $pluginData )
			{

				// skip files directly at root (WP already handles these)
				if( dirname( $pluginFile ) != '.' ){
					$plugins[] = $pluginFile; 
				}

			}

			// OK, set the transient and...
			set_site_transient( static::$transientName, $plugins );

			// ...ship
			return $plugins;

		}/* WPMUPluginFilesInSubDirs() */

		

		/**
		 * Delete the transient if we're on an individual site's plugins page
		 * Require each of the MU plugins
		 *
		 * @author Richard Tape <@richardtape>
		 * @package CTLT_Load_MU_Plugins_In_SubDir
		 * @since 1.0
		 * @param null
		 * @return null
		 */
		
		public function muplugins_loaded__requirePlugins()
		{

			// delete cache when viewing the plugins page in the dashboard
			if( isset( $_SERVER['REQUEST_URI'] ) && strpos( $_SERVER['REQUEST_URI'], '/wp-admin/plugins.php' ) !== false ){
				delete_site_transient( static::$transientName );
			}

			// Now load each plugin in a subdir
			foreach( static::WPMUPluginFilesInSubDirs() as $pluginFile ){
				require WPMU_PLUGIN_DIR . '/' . $pluginFile;
			}

		}/* muplugins_loaded__requirePlugins() */


		/**
		 * Quick and dirty way to display which plugins are MU and slightly adjust their layout 
		 * to show which ones are subdir or not
		 *
		 * @author Richard Tape <@richardtape>
		 * @package CTLT_Load_MU_Plugins_In_SubDir
		 * @since 1.0
		 * @param null
		 * @return null
		 */
		
		public function after_plugin_row__addRows()
		{

			foreach( static::WPMUPluginFilesInSubDirs() as $pluginFile )
			{

				// Super stripped down version of WP_Plugins_List_Table
				$data   = get_plugin_data( WPMU_PLUGIN_DIR . '/' . $pluginFile );
				$name   = empty( $data['Plugin Name'] ) ? $pluginFile : $data['Plugin Name'];
				$id     = sanitize_title( $name );
				$desc   = empty( $data['Description'] ) ? '&nbsp;' : $data['Description'];

				echo static::getPluginRowMarkup( $id, $name, $desc );

			}

		}/* after_plugin_row__addRows() */


		/**
		 * Helper function to output a table row in the MU plugins list
		 *
		 * @author Richard Tape <@richardtape>
		 * @package CTLT_Load_MU_Plugins_In_SubDir
		 * @since 1.0
		 * @param (string) $id - plugin ID (slug of the $name)
		 * @param (string) $name - Name of the plugin
		 * @param (string) $desc - The plugin's description
		 * @return (string) the <tr> markup for this plugin
		 */
		
		public static function getPluginRowMarkup( $id, $name, $desc )
		{

			$output = '
				<tr id="' . $id . '" class="active">
					<th scope="row" class="check-column"></th>
					<td class="plugin-title"><strong style="padding-left: 10px;">+&nbsp;&nbsp;' . $name . '</strong></td>
					<td class="column-description desc">
						<div class="plugin-description"><p>' . $desc . '</p></div>
					</td>
				</tr>
			';

			return apply_filters( 'ctlt_load_mu_plugins_in_sub_dir_tr_markup', $output, $id, $name, $desc );

		}/* getPluginRowMarkup() */
		

	}/* class CTLT_Load_MU_Plugins_In_SubDir */

	$CTLT_Load_MU_Plugins_In_SubDir = new CTLT_Load_MU_Plugins_In_SubDir();