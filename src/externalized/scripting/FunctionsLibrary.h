#pragma once

#include "Facts.h"
#include "Types.h"
#include "Observable.h"
#include <vector>

/*! \file FunctionsLibrary.h */

/*! \struct OBJECTTYPE
    \brief Representation of an inventory item in the game world */
struct OBJECTTYPE;
/*! \struct SECTORINFO
    \brief Status information of a sector */
struct SECTORINFO;
/*! \struct UNDERGROUND_SECTORINFO
    \brief Status information of an underground sector, similar to SECTORINFO but holds slightly different data  */
struct UNDERGROUND_SECTORINFO;
/*! \struct SOLDIERTYPE
    \brief Information and attributes of a soldier in game */
struct SOLDIERTYPE;
/*! \struct MERCPROFILESTRUCT
    \brief Profile of a character in game; controls soldier's name, appearance and others */
struct MERCPROFILESTRUCT;
/*! \struct STRUCTURE
    \brief An structure element on the tactical map */
struct STRUCTURE;
/*! \struct GROUP
    \brief Representation of group of mobile enemies */
struct GROUP;
/*! \struct StrategicMapElement
    \brief Strategic status of ownership and control of a map sector */
struct StrategicMapElement;
/*! \struct STRATEGICEVENT
    \brief An event to scheduled for process at a later time in game */
struct STRATEGICEVENT;

/**
 * @defgroup observables Observables
 * @brief Register listeners on these observables to receive callbacks when somemthing happens in game.
 * @see RegisterListener
 */

 /**
  * Callback when a soldier is created and before the soldier is assigned to teams and placed on map.
  * @param pSoldier pointer to the soldier being created
  * @ingroup observables
  */
extern Observable<SOLDIERTYPE*> OnSoldierCreated;

/**
 * Callback after loading map and before setting it up (e.g. placing soldiers)
 * @ingroup observables
 */
extern Observable<> BeforePrepareSector;

/**
 * Callback right before the structure damange is inflicted.
 * @param sSectorX
 * @param sSectorY
 * @param bSectorZ
 * @param sGridNo location on the tactical map affected by the exploson
 * @param pStructure pointer to the structure to be damaged
 * @param uiDist no of grids from the source of explosion
 * @param fSkipDamage damage processing will be skipped if it is set to TRUE
 * @ingroup observables
 */
extern Observable<INT16, INT16, INT8, INT16, STRUCTURE*, UINT32, BOOLEAN_S*> BeforeStructureDamaged;

/**
  * Callback just after a structure has just been damaged by explosives
  * @param sSectorX
  * @param sSectorY
  * @param bSectorZ
  * @param sGridNo location on map affected by the exploson
  * @param pStructure pointer to the structure being damaged by explosion
  * @param ubDamage damage amount just dealt
  * @param fIsDestroyed whether or not the structure has been destroyed
  * @ingroup observables
  */
extern Observable<INT16, INT16, INT8, INT16, STRUCTURE*, UINT8, BOOLEAN> OnStructureDamaged;
extern Observable<> OnEnterTacticalScreen;
extern Observable<> OnHandleStrategicScreen;
extern Observable<> OnInitNewCampaign;
extern Observable<SOLDIERTYPE*> OnMercHired;
extern Observable<STRATEGICEVENT*, BOOLEAN_S*> OnStrategicEvent;
extern Observable<UINT8_S*> OnCalcPlayerProgress;
extern Observable<BOOLEAN_S*> OnTimeCompressDisallowed;
extern Observable<UINT32, BOOLEAN_S*> OnCheckQuests;
extern Observable<UINT8, INT16, INT16, BOOLEAN> OnQuestEnded;
extern Observable<UINT8, UINT16, UINT8, BOOLEAN_S*> OnNPCDoAction;
extern Observable<INT16, INT16, INT8> OnEnterSector;
extern Observable<INT32, INT32, INT32, UINT8, BOOLEAN, INT32, UINT32, BOOLEAN_S*> OnAddEmail;
extern Observable<SOLDIERTYPE*, OBJECTTYPE*, INT16, INT8> OnSoldierGotItem;

/**
 * @defgroup funclib-general General 
 * @brief Functions to compose mod modules
 */

/**
 * Loads the specified script file into Lua space. The file is loaded via the VFS sub-system.
 * This function can only be used during initialization.
 * @param scriptFileName the name to the lua script file, e.g. enums.lua
 * @ingroup funclib-general
 */
void JA2Require(std::string scriptFileName);

/** @defgroup funclib-sectors Map sectors
 *  @brief Access and alter sectors' stratgic-level data
 */

/**
 * Returns the ID of the current sector, the a format of A11 or B12-1(if underground)
 * @ingroup funclib-sectors
 */
std::string GetCurrentSector();

std::tuple<int, int, int> GetCurrentSectorLoc();

/**
 * Returns a pointer to the SECTOR_INFO of the specified sector. Does not work for underground sectors.
 * @param sectorID the short-string sector ID, e.g. "A10"
 * @throws std::runtime_error if sectorID is empty or invalid
 * @see GetUndergroundSectorInfo
 * @ingroup funclib-sectors
 */
SECTORINFO* GetSectorInfo(std::string const sectorID);

/**
 * Returns a pointer to the UNDERGROUND_SECTORINFO of the specific underground sector.
 * @param sectorID in the format of "XY-Z", e.g. A10-1
 * @see GetSectorInfo
 * @ingroup funclib-sectors
 */
UNDERGROUND_SECTORINFO* GetUndergroundSectorInfo(std::string sectorID);

StrategicMapElement* GetStrategicMapElement(std::string sectorID);

BOOLEAN SetThisSectorAsPlayerControlled(INT16 sMapX, INT16 sMapY, INT8 bMapZ, BOOLEAN fContested);

/** @defgroup funclib-items Items and objects
 *  @brief Functions to handle items, objects and inventories
 */

/**
 * Create a new object of the given item type and returns the pointer to it.
 * @param usItem the ID of the item type
 * @param ubStatus the status of the item, which should be a percentage value between 0 and 100
 * @return a pointer to the created object
 * @ingroup funclib-items
 */
OBJECTTYPE* CreateItem(const UINT16 usItem, const INT8 ubStatus);

/**
 * Creates a new money object of the specified amount
 * @param amt the amount of money
 * @return a pointer to the created object
 * @ingroup funclib-items
 */
OBJECTTYPE* CreateMoney(const UINT32 amt);

/**
 * Places the given object at the specified grid
 * @param sGridNo gridNo to a grid on the current tactical map
 * @param pObject pointer to an object created by CreateItem or CreateMoney
 * @param bVisibility determines if the object is known by the player. Must match one of the Visibility enum
 * @ingroup funclib-items
 */
void PlaceItem(const INT16 sGridNo, OBJECTTYPE* const pObject, const INT8 bVisibility);

MERCPROFILESTRUCT* GetMercProfile(UINT8 ubProfileID);
SOLDIERTYPE* FindSoldierByProfileID(UINT8 profileID);
std::vector<SOLDIERTYPE*> ListSoldiersFromTeam(UINT8 ubTeamID);

void CenterAtGridNo(INT16 sGridNo, bool fForce);

void TriggerNPCRecord(UINT8 ubTriggerNPC, UINT8 record);
void StrategicNPCDialogue(UINT8 ubProfileID, UINT16 usQuoteNum);
BOOLEAN TacticalCharacterDialogue(const SOLDIERTYPE* pSoldier, UINT16 usQuoteNum);
void DeleteTalkingMenu();

void AddEveryDayStrategicEvent_(UINT8 ubCallbackID, UINT32  uiStartMin, UINT32 uiParam);
void AddStrategicEvent_(UINT8 ubCallbackID, UINT32 uiMinStamp, UINT32);
UINT32 GetWorldTotalMin();
UINT32 GetWorldTotalSeconds();

GROUP* CreateNewEnemyGroupDepartingSector(std::string sectorID, UINT8 ubNumAdmins, UINT8 ubNumTroops, UINT8 ubNumElites);

void StartQuest_(UINT8 ubQuestID, std::string sectorID);
void EndQuest_(UINT8 ubQuest, std::string sectorID);

void SetFactTrue(Fact usFact);
void SetFactFalse(Fact usFact);

void ChangeSoldierState(SOLDIERTYPE* pSoldier, UINT16 usNewState, UINT16 usStartingAniCode, BOOLEAN fForce);

void AddEmailMessage(INT32 iMessageOffset, INT32 iMessageLength, INT32 iDate, UINT8 ubSender, BOOLEAN fAlreadyRead, INT32 uiFirstData, UINT32 uiSecondData);
void SetBookMark(INT32 iBookId);
void AddTransactionToPlayersBook(UINT8 ubCode, UINT8 ubSecondCode, UINT32 uiDate, INT32 iAmount);
void AddHistoryToPlayersLog(UINT8 ubCode, UINT8 ubSecondCode, UINT32 uiDate, INT16 sSectorX, INT16 sSectorY);

MERCPROFILESTRUCT* GetMercProfile(UINT8 ubProfileID);

void CenterAtGridNo(INT16 sGridNo, bool fForce);

void TriggerNPCRecord(UINT8 ubTriggerNPC, UINT8 record);

void StrategicNPCDialogue(UINT8 ubProfileID, UINT16 usQuoteNum);

void AddEveryDayStrategicEvent_(UINT8 ubCallbackID, UINT32  uiStartMin, UINT32 uiParam);

void AddStrategicEvent_(UINT8 ubCallbackID, UINT32 uiMinStamp, UINT32);

UINT32 GetWorldTotalMin();
