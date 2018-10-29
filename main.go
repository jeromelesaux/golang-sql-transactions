package main

import (
	"database/sql"
	"fmt"
	_ "github.com/mattn/go-sqlite3"
)

func main() {
	db, err := sql.Open("sqlite3", "tx-test.db3")
	if err != nil {
		panic(err)
	}
	fmt.Printf("Delete all data in table user from tx-test.db3 file\n")
	stmt, err := db.Prepare("delete from user")
	if err != nil {
		panic(err)
	}
	_, err = stmt.Exec()
	if err != nil {
		panic(err)
	}

	fmt.Printf("Testing Transactions\n")
	tx, err := db.Begin()
	if err != nil {
		panic(err)
	}
	insert1, err := tx.Prepare("insert into user(username, firstname, lastname) values ('John','John','Doe')")
	if err != nil {
		fmt.Printf("Rollbacking insert1 gets error %v\n", err)
		panic(err)
	}
	res1, err := insert1.Exec()
	if err != nil {
		fmt.Printf("Cannot execute query error :%v\n", err)
		panic(err)
	}
	fmt.Println(res1.RowsAffected())

	insert2, err := tx.Prepare("insert into user(username, firstname, lastname) values ('Steve','Steve','Jobs')")
	if err != nil {
		fmt.Printf("Rollbacking insert1 gets error %v\n", err)
		panic(err)
	}
	res2, err := insert2.Exec()
	if err != nil {
		fmt.Printf("Cannot execute query error :%v\n", err)
		panic(err)
	}
	fmt.Println(res2.RowsAffected())

	fmt.Printf("Force Rollbacking\n")
	tx.Rollback()

	rows, err := db.Query("select username, firstname, lastname from user")
	if err != nil {
		fmt.Printf("Rollbacking insert1 gets error %v\n", err)
		panic(err)
	}
	var username, firstname, lastname string
	for rows.Next() {
		err = rows.Scan(&username, &firstname, &lastname)
		fmt.Printf("username(%s),firstname(%s),lastname(%s)\n", username, firstname, lastname)
	}
	rows.Close()

	db.Close()

}
