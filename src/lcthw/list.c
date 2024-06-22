#include "list.h"
#include "dbg.h"
#include <assert.h>

List *List_create() {
    return calloc(1, sizeof(List));
}

void List_destroy(List *list) {
    if(list == NULL) {
        return;
    }
    LIST_FOREACH(list, first, next, cur) {
        if(cur->prev) {
            free(cur->prev);
        }
    }

    free(list->last);
    free(list);
}

void List_clear(List *list) {
    if(list == NULL) {
        return;
    }
    LIST_FOREACH(list, first, next, cur) {
        free(cur->value);
    }

}

// before :not very efficient: loop over the list twice.
// after: loops only once.
void List_clear_destroy(List *list) {
    if(list == NULL) {
        return;
    }
    LIST_FOREACH(list, first, next, cur) {
        if(cur->prev) {
            free(cur->prev);
        }
        free(cur->value);
    }

    free(list->last);
    free(list);
}

void List_push(List *list, void *value) {
    if(list == NULL) {
        return;
    }
    ListNode *node = calloc(1, sizeof(ListNode));
    check_mem(node);

    node->value = value;

    if(list->last == NULL) {
        list->first = node;
        list->last = node;
    }
    else {
        list->last->next = node;
        node->prev = list->last;
        list->last = node;
    }

    list->count++;

error:
    return;
}

void *List_pop(List *list) {
    if(list == NULL) {
        return NULL;
    }
    ListNode *node = list->last;
    return node != NULL ? List_remove(list, node) : NULL;
}

void List_unshift(List *list, void *value) {
    if(list == NULL) {
        return;
    }
    ListNode *node = calloc(1, sizeof(ListNode));
    check_mem(node);

    node->value = value;

    if(list->first == NULL) {
        list->first = node;
        list->last = node;
    } else {
        node->next = list->first;
        list->first->prev = node;
        list->first = node;
    }

    list->count++;

error:
    return;
}

void *List_shift(List *list) {
    if(list == NULL) {
        return NULL;
    }
    ListNode *node = list->first;
    return node != NULL ? List_remove(list, node) : NULL;
}

void *List_remove(List *list, ListNode *node) {
    if(list == NULL) {
        return NULL;
    }
    void *result = NULL;

    check(list->first && list->last, "List is empty");
    check(node, "node can't be NULL");

    if(node == list->first && node == list->last) {
        // only one node in list
        list->first = NULL;
        list->last = NULL;
    } else if(node == list->first) {
        // remove the first element
        list->first = node->next;
        check(list->first != NULL, "Invalid list, somehow got a first that is NULL");
        list->first->prev = NULL;
    } else if(node == list->last) {
        // remove the last element
        list->last = node->prev;
        check(list->last != NULL, "Invalid list, somehow got a next that is NULL");
        list->last->next = NULL;
    } else {
        ListNode *after = node->next;
        ListNode *before = node->prev;
        after->prev = before;
        before->next = after;
    }

    list->count--;
    result = node->value;
    free(node);

error:
    return result;
}