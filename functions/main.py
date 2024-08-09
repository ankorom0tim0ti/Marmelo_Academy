# import libraries
from firebase_functions import firestore_fn
from firebase_admin import initialize_app
from threading import Event
import json
import time
from itertools import combinations
import google.generativeai as genai
from google.cloud import firestore
from firebase_admin import credentials
from firebase_admin import firestore
import numpy as np
from datetime import datetime, timedelta
import pytz
import re
from firebase_functions import scheduler_fn
from firebase_functions.firestore_fn import (
    on_document_updated,
    Event,
    Change,
    DocumentSnapshot,
)

# initialize firestor client
initialize_app()
db = firestore.Client()

# timeout setting
TIMEOUT_SECONDS = 540


# function for matching
@firestore_fn.on_document_updated(
    document="users/{docId}", timeout_sec=TIMEOUT_SECONDS, region="asia-northeast1"
)
def matching(event: Event[Change[DocumentSnapshot]]):
    # list of roles
    roles = ["Leader", "Marketer", "Engineer", "Project Manager", "Designer"]
    try:
        doc_system = db.collection("systems").document("matching").get().to_dict()
        processing = doc_system.get("processing") #flag for checking other matching process is running or not
        print(processing) #print function for debugging
        if processing:
            return #do not start the process if another process is running.
        
        # get documtent of user
        doc_ref = db.collection("users").document(event.params["docId"])
        doc = doc_ref.get()

        # get the value associated with the wait key in the dictionary.
        iswait = doc.to_dict().get("wait")

        if iswait == True:  # user is wating for matching

            # setting precessing flag into true to prevent process from collision
            doc_system = db.collection("systems").document("matching")
            doc_system.set({"processing": True}, merge=True) # turn on processing flag
            # get documents of all user
            docs = db.collection("users").stream()

            # prepare temporary map for matching
            match_docs = {}
            role_docs = {}
            name_docs = {}

            # scan all user's document
            for doc in docs:
                # get document of each user as map
                profile = doc.to_dict()

                # get flag of wait from user documtent
                waiting = doc.to_dict().get("wait")

                if waiting:  # determine if the scanned user is in a matching wait state
                    # prepare array for matching reference
                    binary_values = np.array([0, 0, 0, 0, 0])

                    for i in range(0, len(roles)):  # check skill of user
                        if profile["skill"] == roles[i]:
                            binary_values[i] = 1  # turn on flag of skill
                            role_docs[doc.id] = roles[i]  # regiser role
                    match_docs[doc.id] = (
                        binary_values.tolist()
                    )  # store skill array into match docs
                    name_docs[doc.id] = doc.to_dict().get(
                        "displayName"
                    )  # store display name of user into name docs

            # get array of keys of match docs
            keys = list(match_docs.keys())

            if (
                len(keys) >= 5
            ):  # determine if there are more than 5 users, size of group, waiting for matching

                # set matched flag as off
                exist = False

                # prepare tuple for bast matchig group
                best_group = (None, None, None, None, None)

                for key1, key2, key3, key4, key5 in combinations(
                    keys, 5
                ):  # generate all petterns of group
                    # get skill array of each user in picked up group
                    vec1 = np.array(match_docs[key1])
                    vec2 = np.array(match_docs[key2])
                    vec3 = np.array(match_docs[key3])
                    vec4 = np.array(match_docs[key4])
                    vec5 = np.array(match_docs[key5])

                    # store skill arrays in single list
                    vecs = [vec1, vec2, vec3, vec4, vec5]

                    # calc sum of skill arrays
                    vecs_sum = np.sum(vecs, axis=0)

                    # define reference array of matching
                    ref_vec = np.array([1, 1, 1, 1, 1])

                    if np.array_equal(
                        vecs_sum, ref_vec
                    ):  # determine if sum of skill arrays is  equal to reference array
                        # turn flag of matched into true
                        exist = True
                        # store matched group into best group tuple
                        best_group = (key1, key2, key3, key4, key5)

                if exist:  # determine if there are any matched group

                    # generate new sesssion document in sessions collection
                    parent_doc_ref = db.collection("sessions").document()
                    generated_doc_id = parent_doc_ref.id

                    members_interest = []

                    for i in best_group:  # get information of users in matched group
                        # get document of each user in matched group
                        doc_ref = db.collection("users").document(i)

                        dict = doc_ref.get().to_dict().get("interests")

                        members_interest.append(dict)

                        # turn waiting flag into false and register chat id
                        doc_ref.set(
                            {"chat_id": generated_doc_id, "wait": False}, merge=True
                        )

                    all_keys = set.intersection(
                        *[set(d.keys()) for d in members_interest]
                    )

                    # list for contaion common interest
                    common_true_keys = []

                    # check each member's interest
                    for key in all_keys:
                        if all(d.get(key, False) for d in members_interest):
                            common_true_keys.append(key)

                    print("common interest") #print function for debugging
                    print(common_true_keys) #print function for debugging

                    # prepare map of chat member.set complete as
                    members = {
                        key1: {
                            "role": role_docs[key1],
                            "displayName": name_docs[key1],
                            "complete": True,
                        },
                        key2: {
                            "role": role_docs[key2],
                            "displayName": name_docs[key2],
                            "complete": True,
                        },
                        key3: {
                            "role": role_docs[key3],
                            "displayName": name_docs[key3],
                            "complete": True,
                        },
                        key4: {
                            "role": role_docs[key4],
                            "displayName": name_docs[key4],
                            "complete": True,
                        },
                        key5: {
                            "role": role_docs[key5],
                            "displayName": name_docs[key5],
                            "complete": True,
                        },
                    }

                    subcollection_doc_ref = db.collection("sessions").document(
                        generated_doc_id
                    )
                    subcollection_doc_ref.set(
                        {
                            "chat_id": generated_doc_id,  # chat_id
                            "chat_members": members,  # container for chat membert
                            "common_interest": common_true_keys,
                            "members_id": [
                                key1,
                                key2,
                                key3,
                                key4,
                                key5,
                            ],  # ordered members id
                            "sequence": 0,  # proceed with entire process
                            "subsequence": 0,  # proceed with process for each member
                            "app_idea": "",  # data pool for app idea of members
                            "group": "",  # data pool for entire group
                            key1: "",  # data pool for each member
                            key2: "",  # data pool for each member
                            key3: "",  # data pool for each member
                            key4: "",  # data pool for each member
                            key5: "",  # data pool for each member
                            "process": False,
                            "facilitation": {},
                        }
                    )  # map for facilitaion of session

                    # set subsequence as -1 to prepare for initializing session. this process is needed, becaue sequence handler is called when document is updated
                    subcollection_doc_ref.set({"subsequence": -1}, merge=True)

                    # get prompt from backend conficuration document in systems collection and get prompt for first greeting from system
                    doc_ref = db.collection("systems").document("backend_configuration")
                    prompt = str(doc_ref.get().to_dict().get("first_greet"))

                    # send message to group chat for first greeting
                    doc_ref = (
                        db.collection("sessions")
                        .document(generated_doc_id)
                        .collection("messages")
                        .document()
                    )
                    doc_ref.set(
                        {
                            "message": prompt,
                            "user_id": "Marmelo",
                            "displayname": "Marmelo",
                            "timestamp": firestore.SERVER_TIMESTAMP,
                            "private": False,
                            "addres": "all",
                            "ai": False,
                            "role": "marmelo",
                        }
                    )

            doc_system = db.collection("systems").document("matching")
            doc_system.set({"processing": False}, merge=True) # turn off processing flag
    except Exception as e:
        # output error message to console
        print(f"error was occuerd in the matching process: {e}") #print function for debugging


# function for handle message send to system
@firestore_fn.on_document_written(
    document="sessions/{sessionId}/messages/{messageId}",
    timeout_sec=TIMEOUT_SECONDS,
    region="asia-northeast1",
)
def handle_message_system(event: Event[Change[DocumentSnapshot]]):
    try:
        # get event prameters
        session_doc_id = event.params["sessionId"]
        message_doc_id = event.params["messageId"]

        # get document of message
        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document(message_doc_id)
        )
        doc = doc_ref.get()

        # get addres from message
        doc_data = doc.to_dict()
        addres = doc_data.get("addres")

        # determine if addres is system
        if addres != "system":
            return  # system was not called

        else:
            if (
                doc.to_dict().get("response") == None
                and doc.to_dict().get("prompt") == None
            ):  # determine if there is response from gemini ai
                print("system was called") #print function for debugging
                if doc.to_dict().get("ai"):  # determine if gemini processing is needed
                    doc_session = db.collection("sessions").document(session_doc_id)
                    doc_session.set({"process": True}, merge=True)
                    doc_ref = (
                        db.collection("sessions")
                        .document(session_doc_id)
                        .collection("messages")
                        .document(message_doc_id)
                    )
                    doc_ref.set(
                        {"prompt": str(doc.to_dict().get("message"))}, merge=True
                    )  # call chatbot

    except Exception as e:
        # output error message to console
        print(
            f"error was occured in the proess of handling message to system: {str(e)}"
        ) #print function for debugging


# function for handle message send to group chat
@firestore_fn.on_document_written(
    document="sessions/{sessionId}/messages/{messageId}",
    timeout_sec=TIMEOUT_SECONDS,
    region="asia-northeast1",
)
def handle_message_all(event: Event[Change[DocumentSnapshot]]):
    print("handle_message_system was called") #print function for debugging
    try:
        # get event palameter
        session_doc_id = event.params["sessionId"]
        message_doc_id = event.params["messageId"]

        # get document of message
        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document(message_doc_id)
        )
        doc = doc_ref.get()

        # get addres
        addres = doc.to_dict().get("addres")

        if addres != "all":
            return  # addres was not all

        else:
            if (
                doc.to_dict().get("response") == None
            ):  # determine if there is response from gemini
                if doc.to_dict().get("ai"):  # gemini is needed
                    doc_ref = (
                        db.collection("sessions")
                        .document(session_doc_id)
                        .collection("messages")
                        .document(message_doc_id)
                    )
                    doc_ref.set(
                        {"prompt": str(doc.to_dict().get("message"))}, merge=True
                    )  # call chatbot

    except Exception as e:
        # output error message to console
        print(
            f"error was occured in the process of handling message to group: {str(e)}"
        ) #print function for debugging


# function for handle message send to private chat
@firestore_fn.on_document_written(
    document="sessions/{sessionId}/messages/{messageId}",
    timeout_sec=TIMEOUT_SECONDS,
    region="asia-northeast1",
)
def handle_message_private(event: Event[Change[DocumentSnapshot]]):
    try:
        # get event palameter
        session_doc_id = event.params["sessionId"]
        message_doc_id = event.params["messageId"]

        # get document of message
        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document(message_doc_id)
        )
        doc = doc_ref.get()

        addres = doc.to_dict().get("addres")
        if addres == "system" or addres == "all":
            return  # addres was not private chat

        else:  # private was called
            if (
                doc.to_dict().get("response") == None
            ):  # determine if there is response from gemini ai
                if doc.to_dict().get("ai"):

                    doc_system = db.collection("systems").document(
                        "backend_configuration"
                    )
                    assistant_message = str(
                        doc_system.get().to_dict().get("assistant_prompt")
                    )
                    doc_user = str(
                        db.collection("users").document(addres).get().to_dict()
                    )

                    # gemini is needed
                    doc_ref = (
                        db.collection("sessions")
                        .document(session_doc_id)
                        .collection("messages")
                        .document(message_doc_id)
                    )
                    doc_ref.set(
                        {
                            "prompt": assistant_message
                            + str(doc.to_dict().get("message"))
                            + doc_user
                        },
                        merge=True,
                    )  # call chatbot

    except Exception as e:
        print(
            f"error was occued in the process of handling message to private chat: {str(e)}"
        ) #print function for debugging


# function for handle message send to gemini ai
@firestore_fn.on_document_written(
    document="sessions/{sessionId}/messages/{messageId}",
    timeout_sec=TIMEOUT_SECONDS,
    region="asia-northeast1",
)
def handle_message_ai(event: Event[Change[DocumentSnapshot]]):
    try:
        time.sleep(0.1)
        # get event palameter
        session_doc_id = event.params["sessionId"]
        message_doc_id = event.params["messageId"]

        # get document of message
        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document(message_doc_id)
        )
        doc = doc_ref.get()

        # get palameters of message document
        response = doc.to_dict().get("response")
        logged = doc.to_dict().get("logged")
        private = doc.to_dict().get("private")

        if response == None or logged != None:
            return  # ai response was not founded
        elif logged == None:
            doc_ref.set({"logged": True}, merge=True)
            doc_session = db.collection("sessions").document(session_doc_id)
            
            # get addres
            addres = doc.to_dict().get("addres")
            print("document") #print function for debugging
            print(str(doc.to_dict().get("message"))) #print function for debugging

            # message was sent to system
            if addres == "system":
                # get sequence and subsequence of session
                doc_session = db.collection("sessions").document(session_doc_id)
                sequence = doc_session.get().to_dict().get("sequence")
                subsequence = doc_session.get().to_dict().get("subsequence")

                # behavior of sequence except the final stage
                if sequence < 6:
                    addres = "all"
                    private = False
                    doc_ref = (
                        db.collection("sessions")
                        .document(session_doc_id)
                        .collection("messages")
                        .document()
                    )
                    # add gemini response into messages collection
                    doc_ref.set(
                        {
                            "message": response,
                            "user_id": "Marmelo",
                            "displayname": "Marmelo",
                            "timestamp": firestore.SERVER_TIMESTAMP,
                            "private": private,
                            "addres": addres,
                            "role": "marmelo",
                        },
                        merge=True,
                    )

                # behavior of final sequence
                elif sequence == 6:
                    if subsequence == 0:
                        addres = "all"
                        private = False
                        doc_ref = (
                            db.collection("sessions")
                            .document(session_doc_id)
                            .collection("messages")
                            .document()
                        )
                        doc_ref.set(
                            {
                                "message": response,
                                "user_id": "Marmelo",
                                "displayname": "Marmelo",
                                "timestamp": firestore.SERVER_TIMESTAMP,
                                "private": private,
                                "addres": addres,
                                "role": "marmelo",
                            },
                            merge=True,
                        )
                    # perse response of gemini into json data and store json data into firesote
                    if subsequence == 1:
                        print(response) #print function for debugging
                        try:
                            json_data = (
                                response.strip().strip("```json").strip().strip("```")
                            )
                            data = json.loads(json_data)
                            doc_session.set({"facilitation": data}, merge=True)
                            doc_system = db.collection("systems").document(
                                "backend_configuration"
                            )
                            message = str(
                                doc_system.get().to_dict().get("final_greet")
                            )
                            doc_ref = (
                                db.collection("sessions")
                                .document(session_doc_id)
                                .collection("messages")
                                .document()
                            )
                            doc_ref.set(
                                {
                                    "message": message,
                                    "user_id": "Marmelo",
                                    "displayname": "Marmelo",
                                    "timestamp": firestore.SERVER_TIMESTAMP,
                                    "private": False,
                                    "addres": "all",
                                    "ai": False,
                                    "role": "marmelo",
                                }
                            )
                            doc_session.set({"process": False}, merge=True)
                           

                        except Exception as e:  # ugly codeing
                            print(
                                f"error was occued in the process of generate json data of session facilitaiton: {str(e)}"
                            ) #print function for debugging
                            doc_session = db.collection("sessions").document(
                                session_doc_id
                            )
                            doc_session.set(
                                {
                                    "sequence": 6,
                                    "subsequence": 0,
                                },
                                merge=True,
                            )
                            chat_members = (
                                doc_session.get().to_dict().get("chat_members", {})
                            )  # get chat_members data as dictionary list
                            if isinstance(chat_members, dict):
                                for key in chat_members.keys():
                                    if chat_members[key]["role"] == "Leader":
                                        chat_members[key]["complete"] = False
                                    else:
                                        chat_members[key]["complete"] = True
                                doc_session.update(
                                    {"chat_members": chat_members}
                                )  # if sequence or subsequence was proceeded, turn everyone's complete flag into false
                            else:
                                print("chat_members is not dictiorary type") #print function for debugging
                            doc_ref = (
                                db.collection("sessions")
                                .document(session_doc_id)
                                .collection("messages")
                                .document()
                            )
                            doc_ref.set(
                                {
                                    "message": "Data input or somethin is go wrong, So, Please retry to complete your task",
                                    "user_id": "Marmelo",
                                    "displayname": "Marmelo",
                                    "timestamp": firestore.SERVER_TIMESTAMP,
                                    "private": False,
                                    "addres": "all",
                                    "ai": False,
                                    "role": "marmelo",
                                }
                            )
                            pass
                            doc_session.set({"process": False}, merge=True)

                pass  # process for system call. it depends on sequence

            # message was sent to group or private chat
            else:
                print(str(doc.to_dict())) #print function for debugging
                doc_ref = (
                    db.collection("sessions")
                    .document(session_doc_id)
                    .collection("messages")
                    .document()
                )
                doc_ref.set(
                    {
                        "message": response,
                        "user_id": "Marmelo",
                        "displayname": "Marmelo",
                        "timestamp": firestore.SERVER_TIMESTAMP,
                        "private": private,
                        "addres": addres,
                        "role": "marmelo",
                    },
                    merge=True,
                )
            doc_session.set({"process": False}, merge=True)

    except Exception as e:
        print(
            f"error was occued in the process of handling message to gemini ai: {str(e)}"
        ) #print function for debugging


# function for handling sequence of session
@firestore_fn.on_document_updated(
    document="sessions/{sessionId}",
    timeout_sec=TIMEOUT_SECONDS,
    region="asia-northeast1",
)
def handle_sequence(event: Event[Change[DocumentSnapshot]]):
    session_doc_id = event.params["sessionId"]
    try:
        # get event palameter

        # get documemt of session
        doc_ref = db.collection("sessions").document(session_doc_id)
        doc = doc_ref.get()
        doc_dict = doc.to_dict()

        # get session member infomation
        chat_members = doc_dict.get("chat_members", {})

        # check sequence and subsequence
        sequence = doc_dict.get("sequence")
        subsequence = doc_dict.get("subsequence")
        process_flag = doc_dict.get("process")

        # initialize sequence flag as true
        sequence_flag = True

        if isinstance(chat_members, dict):
            for key, value in chat_members.items():
                if value["complete"] == False:
                    sequence_flag = False  # if someone has not completed yet, set the complete flag to false.
        else:
            sequence_flag = False

        if (
            sequence_flag == True and process_flag == False
        ):  # determine if everyone in group is ready for next sequence or subsequence
            # get sequence chart from sequence steps document in system collection
            doc_session = db.collection("sessions").document(session_doc_id)
            doc_session.set({"process": True}, merge=True)

            if isinstance(chat_members, dict):
                for key in chat_members.keys():
                    chat_members[key]["complete"] = False

                # if sequence or subsequence was proceeded, turn everyone's complete flag into false
                doc_ref.update({"chat_members": chat_members})

            doc_system_ref = db.collection("systems").document("sequence_steps")
            doc_system = doc_system_ref.get()
            sequence_list = doc_system.to_dict().get("sequence")

            # increment subsequence
            next_subsequence = subsequence + 1

            if (
                sequence_list[sequence] < next_subsequence
            ):  # determine if all subsequence of sequence was proceeded
                # advance the sequence by one step
                next_sequence = sequence + 1

                # if sequence or subsequence was proceeded, turn everyone's complete flag into false
                doc_ref.update({"sequence": next_sequence, "subsequence": 0})

                # seq manager calls function for each sequence
                seq_manager(session_doc_id, next_sequence, 0)

            else:
                # if sequence or subsequence was proceeded, turn everyone's complete flag into false
                doc_ref.update({"subsequence": next_subsequence})

                # seq manager calls function for each sequence
                seq_manager(session_doc_id, sequence, next_subsequence)
    except Exception as e:
        print(f"error was occued in the process of handling sequence: {str(e)}") #print function for debugging


# function for managing sequence.
def seq_manager(session_doc_id, sequence, subsequence):
    # if process was proceeded. turn process flug into true. this will prevent unintended updates to the sequence

    if sequence == 0:
        seq_0(session_doc_id, subsequence)
    elif sequence == 1:
        seq_1(session_doc_id, subsequence)
    elif sequence == 2:
        seq_2(session_doc_id, subsequence)
    elif sequence == 3:
        seq_3(session_doc_id, subsequence)
    elif sequence == 4:
        seq_4(session_doc_id, subsequence)
    elif sequence == 5:
        seq_5(session_doc_id, subsequence)
    elif sequence == 6:
        seq_6(session_doc_id, subsequence)


# sequence for other instruction
def seq_0(session_doc_id, subsequence):
    print(
        "seq 0 was called from "
        + str(session_doc_id)
        + " and subsequence is "
        + str(subsequence)
    ) #print function for debugging

    # reference user profile for other introduciton
    doc_session = db.collection("sessions").document(session_doc_id)
    user_id_list = doc_session.get().to_dict().get("members_id")
    user_id = user_id_list[subsequence]
    doc_user = db.collection("users").document(user_id)
    doc_user_info = doc_user.get().to_dict()
    user_name = "{user name: " + str(doc_user_info.get("displayName")) + "}"
    user_comany = "{industly: " + str(doc_user_info.get("emplyer")) + "}"
    user_dailytask = "{dailytasks: " + str(doc_user_info.get("dailytasks")) + "}"
    user_holiday = "{holiday: " + str(doc_user_info.get("holiday")) + "}"
    user_interestingAI = (
        "{interesting AI tool: " + str(doc_user_info.get("interestingAI")) + "}"
    )
    uesr_reason = (
        "{reason for interested in AI: " + str(doc_user_info.get("interestingAI")) + "}"
    )
    user_skill = "{skill: " + str(doc_user_info.get("skill")) + "}"
    user_study = (
        "{university studies: " + str(doc_user_info.get("universtiystudies")) + "}"
    )
    user_interest = "{interests : "
    user_interests = doc_user_info.get("interests", {})
    if isinstance(user_interests, dict):
        for key in user_interests.keys():
            if user_interests[key] == True:
                user_interest += "," + key
        user_interest += "}"
    else:
        print("chat_members is not dictonary type") #print function for debugging

    doc_ref = db.collection("sessions").document(session_doc_id)
    doc = doc_ref.get()
    doc_dict = doc.to_dict()
    chat_members = doc_dict.get(
        "chat_members", {}
    )  # get chat_members data as dictionary list
    if isinstance(chat_members, dict):
        for key in chat_members.keys():
            if key == user_id:
                chat_members[key]["complete"] = False
            else:
                chat_members[key]["complete"] = True
        doc_ref.update(
            {"chat_members": chat_members}
        )  # if sequence or subsequence was proceeded, turn everyone's complete flag into false
    else:
        print("chat_members is not dictonary type") #print function for debugging

    # reference prompt of other introduction
    doc_ref = db.collection("systems").document("backend_configuration")
    prompt = str(doc_ref.get().to_dict().get("other_introduction"))

    # call system for generating message
    doc_ref = (
        db.collection("sessions")
        .document(session_doc_id)
        .collection("messages")
        .document()
    )
    prompt = str(
        prompt
        + user_name
        + user_comany
        + user_dailytask
        + user_holiday
        + user_interestingAI
        + uesr_reason
        + user_skill
        + user_study
        + user_interest
    )
    doc_ref.set(
        {
            "message": prompt,
            "user_id": "Marmelo",
            "displayname": "Marmelo",
            "timestamp": firestore.SERVER_TIMESTAMP,
            "private": False,
            "addres": "system",
            "ai": True,
            "role": "marmelo",
        }
    )


def seq_1(session_doc_id, subsequence):  # sequence for ice break
    print(
        "seq 1 was called from "
        + str(session_doc_id)
        + " and subsequence is "
        + str(subsequence)
    ) #print function for debugging
    if subsequence == 0:  # ice break sequence was initialized
        # generate message for explaining ice break game "Two Truths and a Lie"
        doc_system = db.collection("systems").document("backend_configuration")
        message = str(doc_system.get().to_dict().get("ice_break_introduction_group"))
        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document()
        )
        doc_ref.set(
            {
                "message": message,
                "user_id": "Marmelo",
                "displayname": "Marmelo",
                "timestamp": firestore.SERVER_TIMESTAMP,
                "private": False,
                "addres": "all",
                "ai": False,
                "role": "marmelo",
            }
        )

        # generate message for instructing how user should prepare two truths and a lie
        doc_session = db.collection("sessions").document(session_doc_id)
        user_id_list = doc_session.get().to_dict().get("members_id")
        message_person = str(
            doc_system.get().to_dict().get("ice_break_introduction_person")
        )
        for i in user_id_list:
            doc_ref = (
                db.collection("sessions")
                .document(session_doc_id)
                .collection("messages")
                .document()
            )
            doc_ref.set(
                {
                    "message": message_person,
                    "user_id": "Marmelo",
                    "displayname": "Marmelo",
                    "timestamp": firestore.SERVER_TIMESTAMP,
                    "private": True,
                    "addres": str(i),
                    "ai": False,
                    "role": "marmelo",
                }
            )

        doc_session = db.collection("sessions").document(session_doc_id)
        doc_session.set({"process": False}, merge=True)

    elif subsequence == 1:  # every one was ready. start ice break game
        doc_session = db.collection("sessions").document(session_doc_id)
        user_id_list = doc_session.get().to_dict().get("members_id")
        input_data = ""
        doc_ref = db.collection("sessions").document(session_doc_id)
        for i in user_id_list:
            input_data_person = doc_ref.get().to_dict().get(i)
            doc_ref.update({i: ""})
            members = doc_ref.get().to_dict().get("chat_members")
            input_data_person = (
                "##"
                + "Two Truths and a Lie from"
                + members[i]["displayName"]
                + "##"
                + input_data_person
                + "\n"
            )
            input_data += input_data_person
        doc_system = db.collection("systems").document("backend_configuration")
        message = str(doc_system.get().to_dict().get("ice_break_generate"))
        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document()
        )
        doc_ref.set(
            {
                "message": message + input_data,
                "user_id": "Marmelo",
                "displayname": "Marmelo",
                "timestamp": firestore.SERVER_TIMESTAMP,
                "private": False,
                "addres": "system",
                "ai": True,
                "role": "marmelo",
            }
        )

    else:  # summarize the atmosphere of the group and instruct them to come up with app ideas.
        doc_system = db.collection("systems").document("backend_configuration")
        message = str(doc_system.get().to_dict().get("ice_break_conclusion"))
        doc_session = db.collection("sessions").document(session_doc_id)
        chat_log = doc_session.get().to_dict().get("group")
        doc_session.set({"group": ""}, merge=True)
        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document()
        )
        doc_ref.set(
            {
                "message": message + chat_log,
                "user_id": "Marmelo",
                "displayname": "Marmelo",
                "timestamp": firestore.SERVER_TIMESTAMP,
                "private": False,
                "addres": "system",
                "ai": True,
                "role": "marmelo",
            }
        )
        pass


def seq_2(session_doc_id, subsequence):  # sequence fot presenting everyone's app idea
    print(
        "seq 2 was called from "
        + str(session_doc_id)
        + " and subsequence is "
        + str(subsequence)
    ) #print function for debugging
    if subsequence == 0: # collect members app ideas and store into firestore as app_ideas in the first

        app_ideas = ""
        doc_ref = db.collection("sessions").document(session_doc_id)
        doc = doc_ref.get()
        doc_dict = doc.to_dict()
        chat_members = doc_dict.get(
            "chat_members", {}
        )  # get chat_members data as dictionary list
        if isinstance(chat_members, dict):
            for key in chat_members.keys():
                app_ideas += (
                    chat_members[key]["displayName"] + " : " + doc_dict.get(key) + ","
                )
                doc_ref.set(
                    {
                        key: "",
                    },
                    merge=True,
                )
        else:
            print("chat_members is not dictionary type") #print function for debugging

        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document()
        )
        doc_session = db.collection("sessions").document(session_doc_id)
        doc_session.set({"app_ideas": app_ideas, "group": ""}, merge=True)

    doc_session = db.collection("sessions").document(session_doc_id)
    user_id_list = doc_session.get().to_dict().get("members_id")
    user_id = user_id_list[subsequence]
    members = doc_session.get().to_dict().get("chat_members")
    name = members[user_id]["displayName"]

    # reference prompt of app presentation
    doc_system = db.collection("systems").document("backend_configuration")
    prompt = str(doc_system.get().to_dict().get("app_presentation"))

    # call system for generating message
    doc_ref = (
        db.collection("sessions")
        .document(session_doc_id)
        .collection("messages")
        .document()
    )
    app_ideas = doc_session.get().to_dict().get("app_ideas")

    prompt = str(
        prompt + "##selected member : " + name + "\n" + "app ideas : " + app_ideas
    )
    doc_ref.set(
        {
            "message": prompt,
            "user_id": "Marmelo",
            "displayname": "Marmelo",
            "timestamp": firestore.SERVER_TIMESTAMP,
            "private": False,
            "addres": "system",
            "ai": True,
            "role": "marmelo",
        }
    )
    pass


def seq_3(session_doc_id, subsequence):  # sequence for brush up app idea
    print(
        "seq 3 was called from "
        + str(session_doc_id)
        + " and subsequence is "
        + str(subsequence)
    ) #print function for debugging
    doc_ref = db.collection("sessions").document(session_doc_id)
    doc = doc_ref.get()
    doc_dict = doc.to_dict()
    chat_members = doc_dict.get(
        "chat_members", {}
    )  # get chat_members data as dictionary list
    if isinstance(chat_members, dict):
        for key in chat_members.keys():
            if chat_members[key]["role"] == "Leader":
                chat_members[key]["complete"] = False
            else:
                chat_members[key]["complete"] = True
        doc_ref.update(
            {"chat_members": chat_members}
        )  # if sequence or subsequence was proceeded, turn everyone's complete flag into false
    else:
        print("chat_members is not dictionary type") #print function for debugging
    doc_system = db.collection("systems").document("backend_configuration")
    prompt = str(doc_system.get().to_dict().get("app_idea_brush_up"))
    doc_ref = (
        db.collection("sessions")
        .document(session_doc_id)
        .collection("messages")
        .document()
    )
    doc_session = db.collection("sessions").document(session_doc_id)
    app_ideas = doc_session.get().to_dict().get("app_ideas")
    chat_log = doc_session.get().to_dict().get("group")
    doc_session.set({"group": ""}, merge=True)

    prompt = str(
        prompt
        + "##app ideas : "
        + app_ideas
        + "\n"
        + "##chat log of Feed Back of app ideas : "
        + chat_log
    )
    doc_ref.set(
        {
            "message": prompt,
            "user_id": "Marmelo",
            "displayname": "Marmelo",
            "timestamp": firestore.SERVER_TIMESTAMP,
            "private": False,
            "addres": "system",
            "ai": True,
            "role": "marmelo",
        }
    )

    pass


def seq_4(session_doc_id, subsequence):  # sequence for developing the concept of app 1
    print(
        "seq 4 was called from "
        + str(session_doc_id)
        + " and subsequence is "
        + str(subsequence)
    ) #print function for debugging
    doc_session = db.collection("sessions").document(session_doc_id)
    if subsequence == 0:
        chat_members = (
            doc_session.get().to_dict().get("chat_members", {})
        )  # get chat_members data as dictionary list
        selected_app = ""
        if isinstance(chat_members, dict):
            for key in chat_members.keys():
                if chat_members[key]["role"] == "Leader":
                    chat_members[key]["complete"] = False
                    selected_app = doc_session.get().to_dict().get(key)
                else:
                    chat_members[key]["complete"] = True
            doc_session.update(
                {"chat_members": chat_members}
            )  # if sequence or subsequence was proceeded, turn everyone's complete flag into false
        else:
            print("chat_members is not dictionary type") #print function for debugging
        doc_session.set({"app_idea": selected_app}, merge=True)
        doc_system = db.collection("systems").document("backend_configuration")
        message = str(doc_system.get().to_dict().get("app_concept_1"))
        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document()
        )
        doc_ref.set(
            {
                "message": message + selected_app,
                "user_id": "Marmelo",
                "displayname": "Marmelo",
                "timestamp": firestore.SERVER_TIMESTAMP,
                "private": False,
                "addres": "system",
                "ai": True,
                "role": "marmelo",
            }
        )


def seq_5(session_doc_id, subsequence):  # sequence for developing the concept of app 2
    print(
        "seq 5 was called from "
        + str(session_doc_id)
        + " and subsequence is "
        + str(subsequence)
    ) #print function for debugging
    doc_session = db.collection("sessions").document(session_doc_id)
    if subsequence == 0:
        chat_members = (
            doc_session.get().to_dict().get("chat_members", {})
        )  # get chat_members data as dictionary list
        modify_point = ""
        if isinstance(chat_members, dict):
            for key in chat_members.keys():
                if chat_members[key]["role"] == "Leader":
                    chat_members[key]["complete"] = False
                    modify_point = doc_session.get().to_dict().get(key)
                else:
                    chat_members[key]["complete"] = True
            doc_session.update(
                {"chat_members": chat_members}
            )  # if sequence or subsequence was proceeded, turn everyone's complete flag into false
        else:
            print("chat_members is not dictionary type") #print function for debugging
        doc_system = db.collection("systems").document("backend_configuration")
        message = str(doc_system.get().to_dict().get("app_concept_2"))
        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document()
        )
        doc_ref.set(
            {
                "message": message + modify_point,
                "user_id": "Marmelo",
                "displayname": "Marmelo",
                "timestamp": firestore.SERVER_TIMESTAMP,
                "private": False,
                "addres": "system",
                "ai": True,
                "role": "marmelo",
            }
        )
    pass


def seq_6(session_doc_id, subsequence):  # sequence for concludeing session
    print(
        "seq 6 was called from "
        + str(session_doc_id)
        + " and subsequence is "
        + str(subsequence)
    ) #print function for debugging
    doc_session = db.collection("sessions").document(session_doc_id)
    modify_point = ""
    if subsequence == 0:
        chat_members = (
            doc_session.get().to_dict().get("chat_members", {})
        )  # get chat_members data as dictionary list
        if isinstance(chat_members, dict):
            for key in chat_members.keys():
                if chat_members[key]["role"] == "Leader":
                    modify_point = doc_session.get().to_dict().get(key)
                    chat_members[key]["complete"] = False
                else:
                    chat_members[key]["complete"] = True
            doc_session.update(
                {"chat_members": chat_members}
            )  # if sequence or subsequence was proceeded, turn everyone's complete flag into false
        else:
            print("chat_members is not dictionary type") #print function for debugging
        chat_log = doc_session.get().to_dict().get("group")
        doc_session.set({"group": ""}, merge=True)

        personal_information = ""
        user_id_list = doc_session.get().to_dict().get("members_id")
        for i in user_id_list:
            doc_user = db.collection("users").document(i)
            temp_doc = str(doc_user.get().to_dict())
            personal_information += str(temp_doc)
        # generate message for instructing thinking app concept
        doc_system = db.collection("systems").document("backend_configuration")
        message = str(doc_system.get().to_dict().get("facilitation"))
        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document()
        )
        doc_ref.set(
            {
                "message": message + modify_point + personal_information,
                "user_id": "Marmelo",
                "displayname": "Marmelo",
                "timestamp": firestore.SERVER_TIMESTAMP,
                "private": False,
                "addres": "system",
                "ai": True,
                "role": "marmelo",
            }
        )
    elif subsequence == 1:
        print("subsequence 1 of sequence 7 was called") #print function for debugging

        chat_members = (
            doc_session.get().to_dict().get("chat_members", {})
        )  # get chat_members data as dictionary list
        if isinstance(chat_members, dict):
            for key in chat_members.keys():
                if chat_members[key]["role"] == "Leader":
                    modify_point = doc_session.get().to_dict().get(key)
                    chat_members[key]["complete"] = False
                else:
                    chat_members[key]["complete"] = True
            doc_session.update(
                {"chat_members": chat_members}
            )  # if sequence or subsequence was proceeded, turn everyone's complete flag into false
        else:
            print("chat_members is not dictionary type") #print function for debugging

        selected_app = doc_session.get().to_dict().get("app_idea")
        doc_session.set({"group": ""}, merge=True)

        personal_information = ""
        user_id_list = doc_session.get().to_dict().get("members_id")
        for i in user_id_list:
            doc_user = db.collection("users").document(i)
            temp_doc = str(doc_user.get().to_dict())
            personal_information += str(temp_doc)
        # generate message for instructing thinking app concept
        doc_system = db.collection("systems").document("backend_configuration")
        message = str(doc_system.get().to_dict().get("conclusion"))
        doc_ref = (
            db.collection("sessions")
            .document(session_doc_id)
            .collection("messages")
            .document()
        )
        doc_ref.set(
            {
                "message": message + selected_app + modify_point + personal_information,
                "user_id": "Marmelo",
                "displayname": "Marmelo",
                "timestamp": firestore.SERVER_TIMESTAMP,
                "private": False,
                "addres": "system",
                "ai": True,
                "role": "marmelo",
            }
        )


@scheduler_fn.on_schedule(
    schedule="every day 00:00", timezone="Asia/Tokyo", region="asia-northeast1"
)# function to remind next meeting data before the day of next meeting
def remind(event: Event):
    # get current UTC time
    now_utc = datetime.now(pytz.utc)

    # convert into Tokyo time zone
    tokyo_tz = pytz.timezone("Asia/Tokyo")
    now_tokyo = now_utc.astimezone(tokyo_tz)

    # calculate next date
    one_week_later = now_tokyo + timedelta(days=1)

    # get month and day
    month = one_week_later.month
    day = one_week_later.day

    print(f"month of next day: {month}, day of next day: {day}") #print function for debugging

    try:
        # get all documtent of sessions collection from firestore
        sessions_ref = db.collection("sessions")
        docs = sessions_ref.stream()
        
        #get remind message from firestore
        doc_system = db.collection("systems").document("backend_configuration")
        remind = str(doc_system.get().to_dict().get("meeting_reminder"))

        for doc in docs:
            try:
                doc_data = doc.to_dict()
                facilitation = doc_data.get("facilitation", {})
                next_meeting_schedule = facilitation.get("8 Next Meeting Schedule", {})

                print(f"document ID: {doc.id}") #print function for debugging
                print(
                    "the day of next meeting"
                    + str(next_meeting_schedule["8.1 Month"])
                    + " / "
                    + str(next_meeting_schedule["8.2 Day"])
                ) #print function for debugging
                if (
                    next_meeting_schedule["8.1 Month"] == month
                    and next_meeting_schedule["8.2 Day"] == day
                ):
                    # meeting is next day
                    print("meeting is next day") #print function for debugging
                    doc_ref = (
                        db.collection("sessions")
                        .document(doc.id)
                        .collection("messages")
                        .document()
                    )
                    doc_ref.set(
                        {
                            "message": remind,
                            "user_id": "Marmelo",
                            "displayname": "Marmelo",
                            "timestamp": firestore.SERVER_TIMESTAMP,
                            "private": False,
                            "addres": "all",
                            "ai": False,
                            "role": "marmelo",
                        }
                    )

            except Exception as e:
                print(f"documet ID: {doc.id} error was occuered {e}") #print function for debugging

    except Exception as e:
        print(
            f"error was occured in the process of getting documents from collection: {e}"
        ) #print function for debugging

    return
