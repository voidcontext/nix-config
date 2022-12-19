{pkgs, ...}:

{
	
  services.influxdb2.enable = true;
	
	services.telegraf.enable = true;

	services.telegraf.extraConfig.inputs.cpu = {};
	services.telegraf.extraConfig.inputs.mem = {};
	services.telegraf.extraConfig.outputs.influxdb_v2 = {
		urls = ["http://127.0.0.1:8086"];
		token = "uiv3Se6iGBc08XkEnW4vwxFl6qHZlKwl_dVUVGekaLWPdDe-MaBhF_nOWgUTjSMDusAzSTdey42dR4hCWM5XoA==";
		organization = "monitoring";
		bucket = "monitoring";
	};
  
  environment.systemPackages = [
    pkgs.influxdb2
  ];
	
	networking.firewall.interfaces."wg0".allowedTCPPorts = [ 
    8086 # influxdb
  ];
}
