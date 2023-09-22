#pragma semicolon 1
#pragma newdecls required

#include <sdktools_tempents_stocks>
#include <sdktools_stringtables>
#include <sdktools_tempents>

ConVar
	cvHeEffectEnable,
	cvFlEffectEnable,
	cvSmEffectEnable,
	cvEnableDisplay;

int
	iLaser, 
	iHalo,
	iBlackbeam,
	game[4] = {0,1,2,3},	//0-UNDEFINED|1-css34|2-css|3-csgo
	Engine_Version;

int GetCSGame()
{
	if (GetFeatureStatus(FeatureType_Native, "GetEngineVersion") == FeatureStatus_Available) 
	{
		switch (GetEngineVersion())
		{
			case Engine_SourceSDK2006: return game[1];
			case Engine_CSS: return game[2];
			case Engine_CSGO: return game[3];
		}
	}
	return game[0];
}

public APLRes AskPluginLoad2()
{
	if(!(Engine_Version = GetCSGame()))
		SetFailState("Game is not supported!");

	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = "[Any] Nade wave efect/Волны от дитонации гранат(через стены)",
	author = "Nek.'a 2x2 | ggwp.site",
	description = "Волны от дитонации гранат (через стены)",
	version = "1.3.6",
	url = "https://ggwp.site/"
};

public void OnPluginStart()
{
	cvHeEffectEnable = CreateConVar("sm_effecthe_enable", "1", "Включить/выключить эффект взрыва боевой гранаты", _, true, _, true, 1.0);

	cvFlEffectEnable = CreateConVar("sm_effectfl_enable", "1", "Включить/выключить эффект взрыва слеповой гранаты", _, true, _, true, 1.0);
	
	cvSmEffectEnable = CreateConVar("sm_effectsm_enable", "1", "Включить/выключить эффект взрыва дымовой гранаты", _, true, _, true, 1.0);
	
	cvEnableDisplay = CreateConVar("sm_effectinvis_enable", "0", "Включить/выключить видимость эффекта через стены (Только при старте карты)", _, true, _, true, 1.0);
	
	AutoExecConfig(true, "nade_wave_efect");

	HookEvent("hegrenade_detonate", Event_HegrenadeDetonate, EventHookMode_Post);
	HookEvent("flashbang_detonate", Event_FlashbangDetonate, EventHookMode_Post);
	HookEvent("smokegrenade_detonate", Event_SmokegrenadeDetonate, EventHookMode_Post);
}

public void OnConfigsExecuted()
{
	if(!cvEnableDisplay.BoolValue)
	{
		if(Engine_Version == 2)
		{
			iLaser = PrecacheModel("sprites/laser.vmt");
			iHalo = PrecacheModel("sprites/halo.vmt");
			iBlackbeam = PrecacheModel("sprites/blackbeam.vmt", true);
		}
		if(Engine_Version == 1)
		{
			iLaser = PrecacheModel("sprites/laser.vmt");
			iHalo = PrecacheModel("sprites/halo01.vmt");
			iBlackbeam = PrecacheModel("effects/black.vmt", true);
			
		}
		if(Engine_Version == 3)
		{
			iLaser = PrecacheModel("sprites/laserbeam.vmt");
			iHalo = PrecacheModel("sprites/halo.vmt");
			iBlackbeam = PrecacheModel("sprites/blackbeam.vmt", true);
		}
	}
	if(cvEnableDisplay.BoolValue)
	{
		if(Engine_Version == 2)
		{
			iLaser = PrecacheModel("ggwp/sprites/css/laser_wh.vmt");
			iHalo = PrecacheModel("ggwp/sprites/css/halo_wh.vmt");
			iBlackbeam = PrecacheModel("sprites/blackbeam.vmt", true);

			AddFileToDownloadsTable("materials/ggwp/sprites/css/laser_wh.vmt");
			AddFileToDownloadsTable("materials/ggwp/sprites/css/halo_wh.vmt");
		}
		if(Engine_Version == 1)
		{
			iLaser = PrecacheModel("ggwp/sprites/cssv34/laser_wh.vmt");
			iHalo = PrecacheModel("ggwp/sprites/cssv34/halo_wh.vmt");
			iBlackbeam = PrecacheModel("effects/black.vmt", true);

			AddFileToDownloadsTable("materials/ggwp/sprites/cssv34/laser_wh.vmt");
			AddFileToDownloadsTable("materials/ggwp/sprites/cssv34/halo_wh.vmt");
		}
		if(Engine_Version == 3)
		{
			iLaser = PrecacheModel("ggwp/sprites/csgo/laser_wh.vmt");
			iHalo = PrecacheModel("ggwp/sprites/csgo/halo_wh.vmt");
			iBlackbeam = PrecacheModel("sprites/blackbeam.vmt", true);

			AddFileToDownloadsTable("materials/ggwp/sprites/csgo/laser_wh.vmt");
			AddFileToDownloadsTable("materials/ggwp/sprites/csgo/halo_wh.vmt");
		}
	}
}

void Event_HegrenadeDetonate(Event hEvent, const char[] name, bool dontBroadcast)
{
	if(!cvHeEffectEnable.BoolValue)
		return;

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(!IsValidClient(client))
		return;

	float pos[3];
	int color[4]; 
	
	switch(GetRandomInt(1, 5))
	{
		case 1:
		{
			//Первая волна
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)	//т
			{
				color[0] = 0;		//#000080 тёмно синяя
				color[1] = 0;
				color[2] = 128;
			}
			else
			{
				color[0] = 0;			//#00a3cc
				color[1] = 163;
				color[2] = 204;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 0.5, 20.0, 5.0, color, 50, 0);
			TE_SendToAll();

			//вторая внешняя волна
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)	//т
			{
				color[0] = 179;	//#b30000 тёмная вишня
				color[1] = 0;
				color[2] = 0;
			}
			else
			{
				color[0] = 46;		//#2eb82e зелёный
				color[1] = 184;
				color[2] = 46;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 390.0, 10.0, iLaser, iHalo, 0, 0, 0.5, 20.0, 10.0, color, 50, 0);
			TE_SendToAll();
			
			//третья волна ядро
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 128;		//#800000
				color[1] = 0;
				color[2] = 0;
			}
			else
			{
				color[0] = 0;			//#005266
				color[1] = 82;
				color[2] = 102;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 50.0;	//значение высоты
			for (int i = 1; i <= 15; i++) // Создаем цикл. На этот раз радиус один. i просто счетчик высоты. Цилиндр будет высотой 150 единиц.
			{                           // Создаем маяк (кольцо) с нач. диаметром 50.0 ед. и конечным 51.0 единица, чтобы все работало.
				TE_SetupBeamRingPoint(pos, 40.0, 41.0, iLaser, iHalo, 0, 0, 0.5, 10.0, 0.0, color, 50, 0);
				TE_SendToAll();
				pos[2] = pos[2] + 1.0; // Добавляем + 1 единицу к координате Z, чтобы фигура росла в высоту.
			}
		}

		case 2:
		{
			//Первая волна
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)	//т
			{
				color[0] = 102;	//#b30000 фиолетовая
				color[1] = 0;
				color[2] = 204;
			}
			else
			{
				color[0] = 0;			//#00a3cc
				color[1] = 153;
				color[2] = 255;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 0.5, 20.0, 5.0, color, 50, 0);
			TE_SendToAll();

			//вторая внешняя волна
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)	//т
			{
				color[0] = 255;	//Красный
				color[1] = 0;
				color[2] = 0;
			}
			else
			{
				color[0] = 0;		//#2eb82e тёмносиний
				color[1] = 0;
				color[2] = 102;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 390.0, 10.0, iLaser, iHalo, 0, 0, 0.5, 20.0, 10.0, color, 50, 0);
			TE_SendToAll();
			
			//третья волна ядро
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 0;		//#800000
				color[1] = 255;
				color[2] = 0;
			}
			else
			{
				color[0] = 0;			//#005266
				color[1] = 255;
				color[2] = 204;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 50.0;	//значение высоты
			for (int i = 1; i <= 15; i++) // Создаем цикл. На этот раз радиус один. i просто счетчик высоты. Цилиндр будет высотой 150 единиц.
			{                           // Создаем маяк (кольцо) с нач. диаметром 50.0 ед. и конечным 51.0 единица, чтобы все работало.
				TE_SetupBeamRingPoint(pos, 40.0, 41.0, iLaser, iHalo, 0, 0, 0.5, 10.0, 0.0, color, 50, 0);
				TE_SendToAll();
				pos[2] = pos[2] + 1.0; // Добавляем + 1 единицу к координате Z, чтобы фигура росла в высоту.
			}
		}
		case 3:
		{
			//Первая волна
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)	//т
			{
				color[0] = 102;		//#669999 Зёлёно серый
				color[1] = 153;
				color[2] = 153;
			}
			else
			{
				color[0] = 0;			//#009900 Тёмно Зелёный 
				color[1] = 153;
				color[2] = 0;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 0.5, 20.0, 5.0, color, 50, 0);
			TE_SendToAll();

			//вторая внешняя волна
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 204;		//#cc00ff розовый
				color[1] = 0;
				color[2] = 255;
			}
			else
			{
				color[0] = 102;			//#6600ff
				color[1] = 0;
				color[2] = 255;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 390.0, 10.0, iLaser, iHalo, 0, 0, 0.5, 20.0, 10.0, color, 50, 0);
			TE_SendToAll();
			
			//третья волна ядро
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 204;		//#cc00ff розовый
				color[1] = 0;
				color[2] = 255;
			}
			else
			{
				color[0] = 102;			//#6600ff
				color[1] = 0;
				color[2] = 255;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 50.0;	//значение высоты
			for (int i = 1; i <= 15; i++) // Создаем цикл. На этот раз радиус один. i просто счетчик высоты. Цилиндр будет высотой 150 единиц.
			{                           // Создаем маяк (кольцо) с нач. диаметром 50.0 ед. и конечным 51.0 единица, чтобы все работало.
				TE_SetupBeamRingPoint(pos, 40.0, 41.0, iLaser, iHalo, 0, 0, 0.5, 10.0, 0.0, color, 50, 0);
				TE_SendToAll();
				pos[2] = pos[2] + 1.0; // Добавляем + 1 единицу к координате Z, чтобы фигура росла в высоту.
			}
		}
		case 4:
		{
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)	//т
			{
				color[0] = 179;		//#000080 тёмно синяя
				color[1] = 0;
				color[2] = 0;
			}
			else
			{
				color[0] = 0;			//#b30000 тёмно красный
				color[1] = 0;
				color[2] = 128;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 50.0;
			TE_SetupBeamRingPoint(pos, 10.0, 400.0, iLaser, iHalo, 0, 0, 0.5, 40.0, 10.0, color, 50, 0);
			TE_SendToAll();
		}
		case 5:
		{
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)	//т
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			else
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 0.5, 20.0, 5.0, color, 50, 0);
			TE_SendToAll();

			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)	//т
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			else
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 390.0, 10.0, iLaser, iHalo, 0, 0, 0.5, 20.0, 10.0, color, 50, 0);
			TE_SendToAll();
			
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			else
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 50.0;	//значение высоты
			for (int i = 1; i <= 15; i++) // Создаем цикл. На этот раз радиус один. i просто счетчик высоты. Цилиндр будет высотой 150 единиц.
			{                           // Создаем маяк (кольцо) с нач. диаметром 50.0 ед. и конечным 51.0 единица, чтобы все работало.
				TE_SetupBeamRingPoint(pos, 40.0, 41.0, iLaser, iHalo, 0, 0, 0.5, 10.0, 0.0, color, 50, 0);
				TE_SendToAll();
				pos[2] = pos[2] + 1.0; // Добавляем + 1 единицу к координате Z, чтобы фигура росла в высоту.
			}
		}
	}
	
}

void Event_FlashbangDetonate(Event hEvent, const char[] name, bool dontBroadcast)
{
	if(!cvFlEffectEnable.BoolValue)
		return;

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(!IsValidClient(client))
		return;

	float pos[3];
	int color[4]; 

	switch(GetRandomInt(1, 3))
	{
		case 1:
		{
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 235;
				color[1] = 219;
				color[2] = 7;
			}
			else
			{
				color[0] = 255;
				color[1] = 255;
				color[2] = 255;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 40.0;	//значение высоты
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 0.5, 35.0, 0.0, color, 50, 0);
			TE_SendToAll();

			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 235;
				color[1] = 219;
				color[2] = 7;
			}
			else
			{
				color[0] = 255;
				color[1] = 255;
				color[2] = 255;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 80.0;	//значение высоты
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 0.5, 35.0, 0.0, color, 50, 0);
			TE_SendToAll();
			
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 235;
				color[1] = 219;
				color[2] = 7;
			}
			else
			{
				color[0] = 255;
				color[1] = 255;
				color[2] = 255;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 55.0;	//значение высоты
			for (int i = 1; i <= 15; i++) // Создаем цикл. На этот раз радиус один. i просто счетчик высоты. Цилиндр будет высотой 150 единиц.
			{                           // Создаем маяк (кольцо) с нач. диаметром 50.0 ед. и конечным 51.0 единица, чтобы все работало.
				TE_SetupBeamRingPoint(pos, 40.0, 41.0, iLaser, iHalo, 0, 0, 0.5, 10.0, 0.0, color, 50, 0);
				TE_SendToAll();
				pos[2] = pos[2] + 1.0; // Добавляем + 1 единицу к координате Z, чтобы фигура росла в высоту.
			}
		}
		case 2:
		{
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 153;	//993366 бледно красный
				color[1] = 51;
				color[2] = 102;
			}
			else
			{
				color[0] = 204;	//cc6600 коричнеый
				color[1] = 102;
				color[2] = 0;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 40.0;	//значение высоты
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 0.5, 35.0, 0.0, color, 50, 0);
			TE_SendToAll();

			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 153;	//993366 бледно красный
				color[1] = 51;
				color[2] = 102;
			}
			else
			{
				color[0] = 204;	//cc6600 коричнеый
				color[1] = 102;
				color[2] = 0;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 80.0;	//значение высоты
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 0.5, 35.0, 0.0, color, 50, 0);
			TE_SendToAll();
			
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 0;		//#003300 чёрно зелёный
				color[1] = 51;
				color[2] = 0;
			}
			else
			{
				color[0] = 0;	//#
				color[1] = 0;
				color[2] = 102;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 55.0;	//значение высоты
			for (int i = 1; i <= 15; i++) // Создаем цикл. На этот раз радиус один. i просто счетчик высоты. Цилиндр будет высотой 150 единиц.
			{                           // Создаем маяк (кольцо) с нач. диаметром 50.0 ед. и конечным 51.0 единица, чтобы все работало.
				TE_SetupBeamRingPoint(pos, 40.0, 41.0, iLaser, iHalo, 0, 0, 0.5, 10.0, 0.0, color, 50, 0);
				TE_SendToAll();
				pos[2] = pos[2] + 1.0; // Добавляем + 1 единицу к координате Z, чтобы фигура росла в высоту.
			}
		}
		case 3:
		{
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			else
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 40.0;	//значение высоты
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 0.5, 35.0, 0.0, color, 50, 0);
			TE_SendToAll();

			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			else
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 80.0;	//значение высоты
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 0.5, 35.0, 0.0, color, 50, 0);
			TE_SendToAll();
			
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			else
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 55.0;	//значение высоты
			for (int i = 1; i <= 15; i++) // Создаем цикл. На этот раз радиус один. i просто счетчик высоты. Цилиндр будет высотой 150 единиц.
			{                           // Создаем маяк (кольцо) с нач. диаметром 50.0 ед. и конечным 51.0 единица, чтобы все работало.
				TE_SetupBeamRingPoint(pos, 40.0, 41.0, iLaser, iHalo, 0, 0, 0.5, 10.0, 0.0, color, 50, 0);
				TE_SendToAll();
				pos[2] = pos[2] + 1.0; // Добавляем + 1 единицу к координате Z, чтобы фигура росла в высоту.
			}
		}
	}
}

void Event_SmokegrenadeDetonate(Event hEvent, const char[] name, bool dontBroadcast)
{
	if(!cvSmEffectEnable.BoolValue)
		return;

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(!IsValidClient(client))
		return;

	float pos[3];
	int color[4];
	
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			color[1] = 0;
			color[3] = 0;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 255;		//#ff66ff розовый
				color[1] = 102;
				color[2] = 255;
			}
			else
			{
				color[0] = 255;		//#ffff99 светло жёлтый
				color[1] = 255;
				color[2] = 153;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 20.0;	//значение высоты
			TE_SetupBeamRingPoint(pos, 390.0, 10.0, iBlackbeam, iHalo, 0, 0, 3.0, 2.0, 1.0, color, 25, 0);
			TE_SendToAll();

			//Вторая волна
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 0;
				color[1] = 0;
				color[2] = 0;
			}
			else
			{
				color[0] = 0;
				color[1] = 0;
				color[2] = 0;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iBlackbeam, iHalo, 0, 0, 3.0, 5.0, 1.0, color, 25, 0);
			TE_SendToAll();
		}
		case 2:
		{
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 255;
				color[1] = 0;
				color[2] = 255;
			}
			else
			{
				color[0] = 26;
				color[1] = 255;
				color[2] = 26;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 3.0, 30.0, 1.0, color, 25, 0);
			TE_SendToAll();
			
			//Вторая волна
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 255;
				color[1] = 0;
				color[2] = 255;
			}
			else
			{
				color[0] = 26;
				color[1] = 255;
				color[2] = 26;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 20.0;	//значение высоты
			TE_SetupBeamRingPoint(pos, 390.0, 10.0, iLaser, iHalo, 0, 0, 3.0, 30.0, 1.0, color, 25, 0);
			TE_SendToAll();
		}
		case 3:
		{
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 102;		//#660033 тёмно вишнёвый
				color[1] = 0;
				color[2] = 51;
			}
			else
			{
				color[0] = 102;		//#66ccff светло синий
				color[1] = 204;
				color[2] = 255;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 9.0, 10.0, 10.0, color, 25, 0);
			TE_SendToAll();

			//Вторая волна
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = 102;		//#660033 тёмно вишнёвый
				color[1] = 0;
				color[2] = 51;
			}
			else
			{
				color[0] = 102;		//#66ccff светло синий
				color[1] = 204;
				color[2] = 255;
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 20.0;	//значение высоты
			TE_SetupBeamRingPoint(pos, 390.0, 10.0, iLaser, iHalo, 0, 0, 3.0, 30.0, 1.0, color, 25, 0);
			TE_SendToAll();
		}
		case 4:
		{
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			else
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			TE_SetupBeamRingPoint(pos, 10.0, 390.0, iLaser, iHalo, 0, 0, 9.0, 10.0, 10.0, color, 25, 0);
			TE_SendToAll();

			//Вторая волна
			color[1] = 0;
			color[3] = 255;
			if (GetClientTeam(client) == 2)
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			else
			{
				color[0] = GetRandomInt(0, 255);
				color[1] = GetRandomInt(0, 255);
				color[2] = GetRandomInt(0, 255);
			}
			pos[0] = GetEventFloat(hEvent, "x"); pos[1] = GetEventFloat(hEvent, "y"); pos[2] = GetEventFloat(hEvent, "z");
			pos[2] += 20.0;	//значение высоты
			TE_SetupBeamRingPoint(pos, 390.0, 10.0, iLaser, iHalo, 0, 0, 3.0, 30.0, 1.0, color, 25, 0);
			TE_SendToAll();
		}
	}
}

bool IsValidClient(int client)
{
	return 0 < client <= MaxClients && IsClientInGame(client);
}