drop table if exists entries;
create table entries (
	  id integer primary key autoincrement,
	  title text not null,
	  publish text not null,
	  iconPath text,
	  x integer not null,
	  y integer not null
);

