<template>
  <div id="app">
    <transition v-if="new_task.show">
      <section class="add_new_task_wrapper">
        <div class="add_new_task_inner">
          <div class="add_new_task_inner__btn_area">
            <button id="btn_cancel" v-on:click="cancel_new_task" type="button">閉じる</button>
            <span>新しいタスク</span>
            <button id="btn_add" v-on:click="add_new_task" type="button">追加する</button>
          </div>
          <div class="add_new_task_inner__input_area">
            <input v-model="new_task.title" type="text" name="title" placeholder="タスクタイトル" />
            <input v-model="new_task.start_at" type="datetime-local" name="start_at"/>
            <textarea v-model="new_task.detail" placeholder="メモ" class="" rows="4" cols="40" /></textarea>
          </div>
        </div>
      </section>
    </transition>
    <section v-else class="add_new_task_btn">
      <button id="new_task" v-on:click="show_new_task">+</button>
    </section>
    <section v-cloak v-for="month_list in task_list" v-bind:id="month_list.month" class="task_wrapper">
      <h2 class="task_ym">{{month_list.month}}</h2>
      <ul>
        <li v-for="task in month_list.tasks" v-bind:id="'row_task_' + task.id" class="task_list">
          <div>{{task.start_at.slice(8, 10)}} : {{task.title}}</div>
        </li>
      </ul>
    </section>
    <section class="icon_loading" v-observe-visibility="visibilityChanged"><img v-show="isVisible" src="/images/icon_loader.gif"></section>
    <!--load icon-->
  </div>
</template>

<script>
import axios from 'axios';
const token = document.getElementsByName('csrf-token')[0].getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token

export default {
  data: function () {
    return {
      new_task: {
        show: false,
        start_at: '',
        title: '',
        detail: ''
      },
      is_visible_loadicon: true,
      task_list: []
    }
  },
  mounted: function() {
    this.fetch_tasks();
  },
  methods: {
    visibilityChanged: function(is_visible) {
      if (is_visible) {
        // 次のn件をロードする
        var self = this;
        axios.get('/tasks/task_list', {
          params: {
            // this.$data.task_listの一番最後のtaskのstar_atとidを指定する
            next_start_at: "",
            next_id: 123
          }
        }).then((response) => {
          if (response.dataが1件以上のデータが有る時) {
            this.update_tasks(response.data);
          } else {
            this.$data.is_visible_loadicon = false
          }
        })
      }
    },
    add_new_task: function() {
      // api succese or error
      axios.post('/tasks/add_task', {
        task: {
          title: this.$data.new_task.title,
          detail: this.$data.new_task.detail,
          start_at: this.$data.new_task.start_at
        }
      }).then((response) => {
        if (response.data.success) {
          this.$data.new_task.title = '';
          this.$data.new_task.detail = '';
          this.$data.new_task.show = false;
          this.fetch_tasks();
        } else {
          alert("error!")
        }
      });
    },
    cancel_new_task: function() {
      this.$data.new_task.show = false;
    },
    show_new_task: function(event) {
      this.$data.new_task.show = true;
    },
    update_tasks: function(task_array) {
      for (var i in task_array) {
        var task = task_array[i];
        var month = task.start_at.slice(0, 7).replace('-', '/');

        var month_data = this.$data.task_list.find(function(element) {
          return element.month == month;
        });
      	if (typeof(month_data) == 'undefined') {
          month_data = { month: month, tasks: [] }
          this.$data.task_list.push(month_data);
      	}

        var found_index = month_data.tasks.findIndex(function(element) {
          return element.start_at > task.start_at;
        });
        if (found_index >= 0) {
          month_data.tasks.splice(found_index, 0, task);
        } else {
          month_data.tasks.push(task);
        }
      }
    },
    fetch_tasks: function() {
      var self = this;
      axios.get('/tasks/task_list').then((response) => {
        this.update_tasks(response.data);
        console.log(self.$data.task_list);
      })
    }
  }
}

</script>

<style>

</style>
