function names = readDatabase()

% Reads data in a Fame databased and instanciate a dseries object

initialize_dseries_toolbox();

FameInfo = fame.open.connector();

db = fame.open.database(FameInfo, 'FameDataBases/extendlev50.db');

[d, p, n] = fame.getall.timeseries(db);

fame.close.database(db);
fame.close.connector(FameInfo);

ts = dseries(d, p, n);

ts