Level = require 'models/Level'
LevelSession = require 'models/LevelSession'
SuperModel = require 'models/SuperModel'
LevelComponent = require 'models/LevelComponent'
LevelLoader = require 'lib/LevelLoader'

# LEVELS

levelWithOgreWithMace = {
  type: 'hero'
  thangs: [{
    thangType: 'ogre'
    components: [{
      original: LevelComponent.EquipsID
      majorVersion: 0
      config: { inventory: { 'left-hand': 'mace' } }
    }]
  }]
}

levelWithShaman = {
  type: 'hero'
  thangs: [{
    thangType: 'shaman'
  }]
}

levelWithShamanWithSuperWand = {
  type: 'hero'
  thangs: [{
    thangType: 'shaman'
    components: [{
      original: LevelComponent.EquipsID
      majorVersion: 0
      config: { inventory: { 'left-hand': 'super-wand' } }
    }]
  }]
}

# SESSIONS

sessionWithTharinWithHelmet = { heroConfig: { thangType: 'tharin', inventory: { 'head': 'helmet' }}}

# THANG TYPES

thangTypeOgreWithPhysicalComponent = {
  name: 'Ogre'
  original: 'ogre'
  components: [{
    original: 'physical'
    majorVersion: 0
  }]
}

thangTypeShamanWithWandEquipped = {
  name: 'Shaman'
  original: 'shaman'
  components: [{
    original: LevelComponent.EquipsID
    majorVersion: 0
    config: { inventory: { 'left-hand': 'wand' }}
  }]
}

thangTypeTharinWithHealsComponent = {
  name: 'Tharin'
  original: 'tharin'
  components: [{
    original: 'heals'
    majorVersion: 0
  }]
}

thangTypeWand = {
  name: 'Wand'
  original: 'wand'
  components: [{
    original: 'poisons'
    majorVersion: 0
  }]
}



describe 'LevelLoader', ->
  it 'loads hero and item thang types from heroConfig in the LevelSession', ->
    new LevelLoader({supermodel:new SuperModel(), sessionID: 'id', levelID: 'id'})
    
    responses = { 
      '/db/level_session/id': sessionWithTharinWithHelmet 
    }
    
    jasmine.Ajax.requests.sendResponses(responses)
    requests = jasmine.Ajax.requests.all()
    urls = (r.url for r in requests)
    expect('/db/thang.type/helmet/version?project=name,components,original' in urls).toBeTruthy()
    expect('/db/thang.type/tharin/version?project=name,components,original' in urls).toBeTruthy()
    
  it 'loads components for the hero in the heroConfig in the LevelSession', ->
    new LevelLoader({supermodel:new SuperModel(), sessionID: 'id', levelID: 'id'})

    responses = {
      '/db/level_session/id': sessionWithTharinWithHelmet
      '/db/thang.type/tharin/version?project=name,components,original': thangTypeTharinWithHealsComponent
    }

    jasmine.Ajax.requests.sendResponses(responses)
    requests = jasmine.Ajax.requests.all()
    urls = (r.url for r in requests)
    expect('/db/level.component/heals/version/0' in urls).toBeTruthy()
  
  it 'loads thangs for items that the level thangs have in their Equips component configs', ->
    new LevelLoader({supermodel:supermodel = new SuperModel(), sessionID: 'id', levelID: 'id'})
    
    responses = { 
      '/db/level/id': levelWithOgreWithMace 
    }

    jasmine.Ajax.requests.sendResponses(responses)
    requests = jasmine.Ajax.requests.all()
    urls = (r.url for r in requests)
    expect('/db/thang.type/mace/version?project=name,components,original' in urls).toBeTruthy()
  
  it 'loads components which are inherited by level thangs from thang type default components', ->
    new LevelLoader({supermodel:new SuperModel(), sessionID: 'id', levelID: 'id'})

    responses =
      '/db/level/id': levelWithOgreWithMace
      '/db/thang.type/names': [thangTypeOgreWithPhysicalComponent]

    jasmine.Ajax.requests.sendResponses(responses)
    requests = jasmine.Ajax.requests.all()
    urls = (r.url for r in requests)
    expect('/db/level.component/physical/version/0' in urls).toBeTruthy()
  
  it 'loads item thang types which are inherited by level thangs from thang type default equips component configs', ->
    new LevelLoader({supermodel:new SuperModel(), sessionID: 'id', levelID: 'id'})

    responses =
      '/db/level/id': levelWithShaman
      '/db/thang.type/names': [thangTypeShamanWithWandEquipped]

    jasmine.Ajax.requests.sendResponses(responses)
    requests = jasmine.Ajax.requests.all()
    urls = (r.url for r in requests)
    expect('/db/thang.type/wand/version?project=name,components,original' in urls).toBeTruthy()
  
  it 'loads components for item thang types which are inherited by level thangs from thang type default equips component configs', ->
    new LevelLoader({supermodel:new SuperModel(), sessionID: 'id', levelID: 'id'})

    responses =
      '/db/level/id': levelWithShaman
      '/db/thang.type/names': [thangTypeShamanWithWandEquipped]
      '/db/thang.type/wand/version?project=name,components,original': thangTypeWand

    jasmine.Ajax.requests.sendResponses(responses)
    requests = jasmine.Ajax.requests.all()
    urls = (r.url for r in requests)
    expect('/db/level.component/poisons/version/0' in urls).toBeTruthy()
    
  it 'does not load item thang types from thang type equips component configs which are overriden by level thang equips component configs', ->
    new LevelLoader({supermodel:new SuperModel(), sessionID: 'id', levelID: 'id'})

    responses =
      '/db/level/id': levelWithShamanWithSuperWand
      '/db/thang.type/names': [thangTypeShamanWithWandEquipped]

    jasmine.Ajax.requests.sendResponses(responses)
    requests = jasmine.Ajax.requests.all()
    urls = (r.url for r in requests)
    expect('/db/thang.type/wand/version?project=name,components,original' in urls).toBeFalsy()
