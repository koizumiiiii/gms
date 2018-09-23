<template>
  <div id="app">
      <section v-if="new_task.visible" class="add_new_task_wrapper" id="getHeight">
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
        visible: false,
        start_at: '',
        title: '',
        detail: ''
      },
      task_list: []
    }
  },
  mounted: function() {
    this.fetch_tasks();
  },
  methods: {
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
          this.$data.new_task.visible = false;
          this.fetch_tasks();
        } else {
          alert("error!")
        }
      });
    },
    cancel_new_task: function() {
      this.$data.new_task.visible = false;
    },
    show_new_task: function(event) {
      this.$data.new_task.visible = true;
    },
    fetch_tasks: function() {
      var self = this;
      axios.get('/tasks/task_list').then((response) => {
        var task_array = response.data;
        var month_data = { month: null, tasks: []}
        for (var i in task_array) {
          var task = task_array[i];
          var month = task.start_at.slice(0, 7).replace('-', '/');

          if (month_data.month == month) {
            month_data.tasks.push(task);
          } else {
            if (month_data.month != null) {
              self.$data.task_list.push(month_data);
            }
            month_data = {
              month: month,
              tasks: [task]
            }
          }
        }
        if (month_data.tasks.length > 0) {
          self.$data.task_list.push(month_data);
        }
      })
    }
  }
}

</script>

<style>

</style>
